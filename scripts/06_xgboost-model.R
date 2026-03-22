source("renv/activate.R")

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

plot_theme <- theme_bw(base_size = 11) +
  theme(
    plot.title   = element_text(hjust = 0.5, size = 12),
    axis.text.x  = element_text(size = 9),
    axis.text.y  = element_text(size = 9),
    axis.title.x = element_text(size = 10),
    axis.title.y = element_text(size = 10)
  )

vip_plot <- xgb_fit_initial |>
  extract_fit_parsnip() |>
  vip(num_features = 15) +
  labs(title = "XGBoost Feature Importance") +
  plot_theme

ggsave(
  "results/figures/21_xgboost-feature-importance.png",
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
  filter(.metric == "j_index") |>
  arrange(desc(mean)) |>
  slice(1)

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

xgb_val_metrics <- xgb_val_predictions |>
  metric_set(j_index, sensitivity, accuracy)(
    truth    = stroke,
    estimate = .pred_class
  )

write_csv(
  xgb_val_metrics,
  "results/tables/11_xgboost-validation-metrics.csv"
)

xgb_confusion <- xgb_val_predictions |>
  conf_mat(truth = stroke, estimate = .pred_class)

write_csv(
  as_tibble(xgb_confusion$table),
  "results/tables/12_xgboost-confusion-matrix.csv"
)