source("renv/activate.R")
source("scripts/functions/evaluate_model.R")
source("scripts/functions/plot_confusion_matrix.R")
source("scripts/functions/select_best_params.R")
source("scripts/functions/set_plot_theme.R")
set_plot_theme()

library(docopt)
library(tidyverse)
library(tidymodels)
library(MASS)
library(themis)

set.seed(894235)

doc <- "
Usage: 05_logreg-model.R --training=<path> --validation=<path> --out_figures_dir=<dir> --out_tables_dir=<dir> --out_models_dir=<dir>

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
  mutate(across(all_of(factor_cols), factor)) |>
  dplyr::select(-id)

stroke_validation <- read_csv(validation_path) |>
  mutate(across(all_of(factor_cols), factor))

# Backward selection
logr_recipe_for_selection <- recipe(
  stroke ~ gender + age + hypertension + heart_disease +
    residence_type + avg_glucose_level + bmi + smoking_status,
  data = stroke_training
) |>
  step_YeoJohnson(all_numeric_predictors()) |>
  step_scale(all_numeric_predictors()) |>
  step_center(all_numeric_predictors()) |>
  step_dummy(all_nominal_predictors())

baked_train <- prep(logr_recipe_for_selection) |>
  bake(new_data = NULL)

full_glm <- glm(stroke ~ ., data = baked_train, family = binomial)
backward_glm <- MASS::stepAIC(full_glm, direction = "backward", trace = FALSE)

survived_terms <- attr(terms(backward_glm), "term.labels")
write_csv(
  tibble(term = survived_terms),
  file.path(out_tables_dir, "06_logreg-backward-selection-terms.csv")
)

# Recipe with selected predictors
original_predictors <- setdiff(names(stroke_training), "stroke")
selected_predictors <- original_predictors[sapply(original_predictors, function(col) {
  any(survived_terms == col |
    startsWith(survived_terms, paste0(col, "_")))
})]

logr_recipe_final <- recipe(
  reformulate(selected_predictors, response = "stroke"),
  data = stroke_training
) |>
  step_YeoJohnson(all_numeric_predictors()) |>
  step_scale(all_numeric_predictors()) |>
  step_center(all_numeric_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_smote(stroke)

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
  file.path(out_tables_dir, "07_logreg-best-params.csv")
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

saveRDS(logr_fit, file.path(out_models_dir, "logr_fit.rds"))

logr_val_predictions <- predict(logr_fit, stroke_validation) |>
  bind_cols(stroke_validation)

evaluate_model(
  predictions         = logr_val_predictions,
  metric_save_path    = file.path(out_tables_dir, "08_logreg-validation-metrics.csv"),
  confusion_save_path = file.path(out_tables_dir, "09_logreg-confusion-matrix.csv")
)

#For confusion matrix plot
logreg_cm_plot <- plot_confusion_matrix(
  confusion_save_path = file.path(out_tables_dir, "09_logreg-confusion-matrix.csv"),
  title               = "Logistic Regression Confusion Matrix (Validation Set)"
)

ggplot2::ggsave(
  filename = file.path(out_figures_dir, "22_logreg-confusion-matrix.png"),
  plot     = logreg_cm_plot,
  width    = 6,
  height   = 6
)

