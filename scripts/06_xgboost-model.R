source("renv/activate.R")
source("scripts/functions/evaluate_model.R")
source("scripts/functions/select_best_params.R")
source("scripts/functions/plot_confusion_matrix.R") 
source("scripts/functions/set_plot_theme.R")
set_plot_theme()
source("scripts/functions/create_stroke_recipe.R")

library(tidyverse)
library(tidymodels)
library(themis)
library(vip)
library(finetune)

set.seed(894235)

# Load data 

factor_cols <- c(
  "gender", "work_type", "residence_type", "smoking_status",
  "hypertension", "ever_married", "heart_disease", "stroke"
)

stroke_training <- read_csv("data/processed/stroke_training.csv") |>
  mutate(across(all_of(factor_cols), factor))

stroke_validation <- read_csv("data/processed/stroke_validation.csv") |>
  mutate(across(all_of(factor_cols), factor))

# Feature importance via initial model

xgb_recipe_full <- create_stroke_recipe(
  training_data = stroke_training,
  response      = "stroke",
  predictors    = c(
    "gender", "age", "hypertension", "heart_disease",
    "residence_type", "avg_glucose_level", "bmi", "smoking_status"
  ),
  smote = TRUE
)

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
  "results/figures/21_xgboost-feature-importance.png",
  plot   = vip_plot,
  width  = 8,
  height = 6
)

# Hyperparameter tuning

xgb_recipe_selected <- create_stroke_recipe(
  training_data = stroke_training,
  response      = "stroke",
  predictors    = c(
    "age", "avg_glucose_level", "bmi",
    "hypertension", "heart_disease", "smoking_status", "residence_type"
  ),
  smote = TRUE
)

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
  "results/tables/10_xgboost-best-params.csv"
)

# Final model

xgb_fit <- xgb_wf |>
  finalize_workflow(best_xgb_params) |>
  fit(data = stroke_training)

dir.create("results/models", recursive = TRUE, showWarnings = FALSE)
saveRDS(xgb_fit, "results/models/xgb_fit.rds")

xgb_val_predictions <- predict(xgb_fit, stroke_validation) |>
  bind_cols(stroke_validation)

evaluate_model(
  predictions         = xgb_val_predictions,
  metric_save_path    = "results/tables/11_xgboost-validation-metrics.csv",
  confusion_save_path = "results/tables/12_xgboost-confusion-matrix.csv"
)

xgboost_cm_plot <- plot_confusion_matrix(
  confusion_save_path = "results/tables/12_xgboost-confusion-matrix.csv",
  title               = "XGBoost Confusion Matrix (Validation Set)"
)

ggplot2::ggsave(
  filename = "results/figures/23_xgboost-confusion-matrix.png",
  plot     = xgboost_cm_plot,
  width    = 6,
  height   = 6
)
