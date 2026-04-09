source("renv/activate.R")
library(exploretraintest)

set_plot_theme()


library(docopt)
library(tidyverse)
library(tidymodels)
library(themis)

set.seed(894235)

doc <- "
Usage: 04_knn-model.R --training=<path> --validation=<path> --out_figures_dir=<dir> --out_tables_dir=<dir> --out_models_dir=<dir>

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
  select(-id)

stroke_validation <- read_csv(validation_path) |>
  mutate(across(all_of(factor_cols), factor))


stroke_recipe <- create_stroke_recipe(
  training_data = stroke_training,
  response      = "stroke",
  predictors    = c(
    "gender", "age", "hypertension", "heart_disease",
    "residence_type", "avg_glucose_level", "bmi", "smoking_status"
  ),
  smote = TRUE
)

# Coarse Sweep
stroke_knn_classifier <- nearest_neighbor(
  weight_func = "rectangular",
  neighbors   = tune()
) |>
  set_engine("kknn") |>
  set_mode("classification")

stroke_knn_vfold  <- vfold_cv(stroke_training, v = 5, strata = stroke)
coarse_knn_k_vals <- tibble(neighbors = seq(from = 1, to = 200, by = 10))

coarse_knn_cv_sweep_results <- workflow() |>
  add_recipe(stroke_recipe) |>
  add_model(stroke_knn_classifier) |>
  tune_grid(
    resamples = stroke_knn_vfold,
    grid      = coarse_knn_k_vals,
    metrics   = metric_set(j_index, sensitivity, accuracy)
  ) |>
  collect_metrics()

write_csv(
  coarse_knn_cv_sweep_results,
  file.path(out_tables_dir, "02_coarse-knn-cv-results.csv")
)

coarse_n_neighbors_plot <- coarse_knn_cv_sweep_results |>
  filter(.metric == "j_index") |>
  ggplot(aes(x = neighbors, y = mean)) +
  geom_line() +
  labs(
    title = "J-Index vs # of Neighbours for kNN Model",
    x     = "# of Neighbours",
    y     = "Mean J-Index"
  )

ggsave(
  file.path(out_figures_dir, "20_coarse-knn-k-sweep.png"),
  plot   = coarse_n_neighbors_plot,
  width  = 8,
  height = 5
)

# Fine sweep
best_coarse_k <- select_best_params(coarse_knn_cv_sweep_results) |>
  pull(neighbors)

fine_knn_k_vals <- tibble(
  neighbors = seq(from = best_coarse_k - 10, to = best_coarse_k + 10, by = 1)
)

fine_knn_cv_sweep_results <- workflow() |>
  add_recipe(stroke_recipe) |>
  add_model(stroke_knn_classifier) |>
  tune_grid(
    resamples = stroke_knn_vfold,
    grid      = fine_knn_k_vals,
    metrics   = metric_set(j_index, sensitivity, accuracy)
  ) |>
  collect_metrics()

write_csv(
  fine_knn_cv_sweep_results,
  file.path(out_tables_dir, "03_fine-knn-cv-results.csv")
)

best_k <- select_best_params(fine_knn_cv_sweep_results) |>
  pull(neighbors)

# Final model
knn_model_final <- nearest_neighbor(
  weight_func = "rectangular",
  neighbors   = best_k
) |>
  set_engine("kknn") |>
  set_mode("classification")

knn_stroke_fit <- workflow() |>
  add_model(knn_model_final) |>
  add_recipe(stroke_recipe) |>
  fit(data = stroke_training)

saveRDS(knn_stroke_fit, file.path(out_models_dir, "knn_fit.rds"))

knn_stroke_predictions <- predict(knn_stroke_fit, stroke_validation) |>
  bind_cols(stroke_validation)

evaluate_model(
  predictions         = knn_stroke_predictions,
  metric_save_path    = file.path(out_tables_dir, "04_knn-validation-metrics.csv"),
  confusion_save_path = file.path(out_tables_dir, "05_knn-confusion-matrix.csv")
)

#For confusion matrix plot
knn_cm_plot <- plot_confusion_matrix(
  confusion_save_path = file.path(out_tables_dir, "05_knn-confusion-matrix.csv"),
  title               = "k-NN Confusion Matrix (Validation Set)"
)

ggplot2::ggsave(
  filename = file.path(out_figures_dir, "21_knn-confusion-matrix.png"),
  plot     = knn_cm_plot,
  width    = 6,
  height   = 6
)
