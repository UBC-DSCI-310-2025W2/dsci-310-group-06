source("renv/activate.R")
source("scripts/functions/evaluate_model.R")
source("scripts/functions/select_best_params.R")
source("scripts/functions/plot_confusion_matrix.R")
source("scripts/functions/set_plot_theme.R")
set_plot_theme()

library(docopt)
library(tidyverse)
library(tidymodels)
library(themis)
library(vip)
library(finetune)

set.seed(894235)

doc <- "
Usage: 06_xgboost-model.R --training=<path> --validation=<path> --out_figures_dir=<dir> --out_tables_dir=<dir> --out_models_dir=<dir>

Options:
  --training=<path>        Path to training CSV
  --validation=<path>      Path to validation CSV
  --out_figures_dir=<dir>  Directory for output figures
  --out_tables_dir=<dir>   Directory for output tables
  --out_models_dir=<dir>   Directory for output models
"

opts            <- docopt(doc)
training_path   <- opts$training
validation_path <- opts$validation
out_figures_dir <- opts$out_figures_dir
out_tables_dir  <- opts$out_tables_dir
out_models_dir  <- opts$out_models_dir

dir.create(out_figures_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(out_tables_dir,  recursive = TRUE, showWarnings = FALSE)
dir.create(out_models_dir,  recursive = TRUE, showWarnings = FALSE)

# Load data

factor_cols <- c(
  "gender", "work_type", "residence_type", "smoking_status",
  "hypertension", "ever_married", "heart_disease", "stroke"
)

stroke_training <- read_csv(training_path) |>
  mutate(across(all_of(factor_cols), factor))

stroke_validation <- read_csv(validation_path) |>
  mutate(across(all_of(factor_cols), factor))

# Feature importance via initial model

xgb_recipe_full <- recipe(
  stroke ~ gender + age + hypertension + heart_disease +
    residence_type + avg_glucose_level + bmi + smoking_status,
  data = stroke_training
) |>
  step_YeoJohnson(all_numeric_predictors()) |>
  step_scale(all_numeric_predictors()) |>
  step_center(all_numeric_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_smote(stroke)

xgb_spec_initial <- boost_tree(trees = 200) |>
  set_engine("xgboost") |>
  set_mode("classification")

xgb_fit_initial <- workflow() |>
  add_recipe(xgb_recipe_full) |>
  add_model(xgb_spec_initial) |>
  fit(data = stroke_training)

vip_plot <- xgb_fit_initial |>
  extract_fit_parsnip() |>
  vip(num_features = 15) +
  labs(title = "XGBoost Feature Importance")

ggsave(
  file.path(out_figures_dir, "21_xgboost-feature-importance.png"),
  plot   = vip_plot,
  width  = 8,
  height = 6
)

# Hyperparameter tuning

xgb_recipe_selected <- recipe(
  stroke ~ age + avg_glucose_level + bmi +
    hypertension + heart_disease + smoking_status + residence_type,
  data = stroke_training
) |>
  step_YeoJohnson(all_numeric_predictors()) |>
  step_scale(all_numeric_predictors()) |>
  step_center(all_numeric_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_smote(stroke)

xgb_spec_tune <- boost_tree(
  trees          = tune(),
  tree_depth     = tune(),
  learn_rate     = tune(),
  min_n          = tune(),
  loss_reduction = tune(),
  sample_size    = tune()
) |>
  set_engine("xgboost") |>
  set_mode("classification")

xgb_vfold <- vfold_cv(stroke_training, v = 5, strata = stroke)

xgb_wf <- workflow() |>
  add_recipe(xgb_recipe_selected) |>
  add_model(xgb_spec_tune)

xgb_params <- xgb_wf |>
  extract_parameter_set_dials() |>
  update(
    learn_rate = learn_rate(range = c(-3, -1)),
    trees      = trees(range = c(100, 1000))
  )

xgb_bayes_results <- xgb_wf |>
  tune_bayes(
    resamples  = xgb_vfold,
    param_info = xgb_params,
    iter       = 30,
    initial    = 10,
    metrics    = metric_set(j_index, sensitivity, accuracy),
    control    = control_bayes(no_improve = 10, verbose = FALSE)
  )

best_xgb_params <- xgb_bayes_results |>
  collect_metrics() |>
  select_best_params()

write_csv(
  best_xgb_params,
  file.path(out_tables_dir, "10_xgboost-best-params.csv")
)

# Final model

xgb_fit <- xgb_wf |>
  finalize_workflow(best_xgb_params) |>
  fit(data = stroke_training)

saveRDS(xgb_fit, file.path(out_models_dir, "xgb_fit.rds"))

xgb_val_predictions <- predict(xgb_fit, stroke_validation) |>
  bind_cols(stroke_validation)

evaluate_model(
  predictions         = xgb_val_predictions,
  metric_save_path    = file.path(out_tables_dir, "11_xgboost-validation-metrics.csv"),
  confusion_save_path = file.path(out_tables_dir, "12_xgboost-confusion-matrix.csv")
)

xgboost_cm_plot <- plot_confusion_matrix(
  confusion_save_path = file.path(out_tables_dir, "12_xgboost-confusion-matrix.csv"),
  title               = "XGBoost Confusion Matrix (Validation Set)"
)

ggplot2::ggsave(
  filename = file.path(out_figures_dir, "24_xgboost-confusion-matrix.png"),
  plot     = xgboost_cm_plot,
  width    = 6,
  height   = 6
)
