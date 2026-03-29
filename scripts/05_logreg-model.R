source("renv/activate.R")
source("scripts/functions/evaluate_model.R")
source("scripts/functions/plot_confusion_matrix.R")
source("scripts/functions/select_best_params.R")
source("scripts/functions/set_plot_theme.R")
set_plot_theme()
source("scripts/functions/create_stroke_recipe.R")

library(tidyverse)
library(tidymodels)
library(MASS)
library(themis)

set.seed(894235)

# Load data 
factor_cols <- c(
  "gender", "work_type", "residence_type", "smoking_status",
  "hypertension", "ever_married", "heart_disease", "stroke"
)

stroke_training <- read_csv("data/processed/stroke_training.csv") |>
  mutate(across(all_of(factor_cols), factor)) |>
  dplyr::select(-id)

stroke_validation <- read_csv("data/processed/stroke_validation.csv") |>
  mutate(across(all_of(factor_cols), factor))

# Backward selection
logr_recipe_for_selection <- create_stroke_recipe(
  training_data = stroke_training,
  response      = "stroke",
  predictors    = c(
    "gender", "age", "hypertension", "heart_disease",
    "residence_type", "avg_glucose_level", "bmi", "smoking_status"
  ),
  smote = FALSE
)

baked_train <- prep(logr_recipe_for_selection) |>
  bake(new_data = NULL)

full_glm <- glm(stroke ~ ., data = baked_train, family = binomial)
backward_glm <- MASS::stepAIC(full_glm, direction = "backward", trace = FALSE)

survived_terms <- attr(terms(backward_glm), "term.labels")
write_csv(
  tibble(term = survived_terms),
  "results/tables/06_logreg-backward-selection-terms.csv"
)

# Recipe with selected predictors
original_predictors <- setdiff(names(stroke_training), "stroke")
selected_predictors <- original_predictors[sapply(original_predictors, function(col) {
  any(survived_terms == col |
    startsWith(survived_terms, paste0(col, "_")))
})]

logr_recipe_final <- create_stroke_recipe(
  training_data = stroke_training,
  response      = "stroke",
  predictors    = selected_predictors,
  smote         = TRUE
)

# Hyperparameter tuning

logr_spec <- logistic_reg(penalty = tune(), mixture = tune()) |>
  set_engine("glmnet") |>
  set_mode("classification")

logr_grid <- grid_regular(
  penalty(range = c(-5, 0)),
  mixture(range = c(0, 1)),
  levels = 10
)

logr_vfold <- vfold_cv(stroke_training, v = 5, strata = stroke)

logr_cv_results <- workflow() |>
  add_recipe(logr_recipe_final) |>
  add_model(logr_spec) |>
  tune_grid(
    resamples = logr_vfold,
    grid      = logr_grid,
    metrics   = metric_set(j_index, sensitivity, accuracy)
  ) |>
  collect_metrics()

best_logr_params <- select_best_params(logr_cv_results)

write_csv(
  best_logr_params,
  "results/tables/07_logreg-best-params.csv"
)

# Final model
logr_final_spec <- logistic_reg(
  penalty = best_logr_params$penalty,
  mixture = best_logr_params$mixture
) |>
  set_engine("glmnet") |>
  set_mode("classification")

logr_fit <- workflow() |>
  add_recipe(logr_recipe_final) |>
  add_model(logr_final_spec) |>
  fit(data = stroke_training)

dir.create("results/models", recursive = TRUE, showWarnings = FALSE)
saveRDS(logr_fit, "results/models/logr_fit.rds")

logr_val_predictions <- predict(logr_fit, stroke_validation) |>
  bind_cols(stroke_validation)

evaluate_model(
  predictions         = logr_val_predictions,
  metric_save_path    = "results/tables/08_logreg-validation-metrics.csv",
  confusion_save_path = "results/tables/09_logreg-confusion-matrix.csv"
)

#For confusion matrix plot
logreg_cm_plot <- plot_confusion_matrix(
  confusion_save_path = "results/tables/09_logreg-confusion-matrix.csv",
  title               = "Logistic Regression Confusion Matrix (Validation Set)"
)

ggplot2::ggsave(
  filename = "results/figures/22_logreg-confusion-matrix.png",
  plot     = logreg_cm_plot,
  width    = 6,
  height   = 6
)

