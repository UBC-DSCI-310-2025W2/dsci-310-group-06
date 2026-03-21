source("renv/activate.R")

library(tidyverse)
library(tidymodels)
library(themis)

set.seed(894235)

# Load data
factor_cols <- c(
  "gender", "work_type", "residence_type", "smoking_status",
  "hypertension", "ever_married", "heart_disease", "stroke"
)

stroke_training <- read_csv("data/processed/stroke_training.csv") |>
  mutate(across(all_of(factor_cols), factor)) |>
  select(-id)

stroke_validation <- read_csv("data/processed/stroke_validation.csv") |>
  mutate(across(all_of(factor_cols), factor))


stroke_recipe <- recipe(
  stroke ~ gender + age + hypertension + heart_disease +
    residence_type + avg_glucose_level + bmi + smoking_status,
  data = stroke_training
) |>
  step_YeoJohnson(all_numeric_predictors()) |>
  step_scale(all_numeric_predictors()) |>
  step_center(all_numeric_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_smote(stroke)

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
  "results/tables/02_coarse-knn-cv-results.csv"
)

coarse_n_neighbors_plot <- coarse_knn_cv_sweep_results |>
  filter(.metric == "j_index") |>
  ggplot(aes(x = neighbors, y = mean)) +
  geom_line() +
  labs(
    title = "Figure 20. J-Index vs # of Neighbours for kNN Model",
    x     = "# of Neighbours",
    y     = "Mean J-Index"
  ) +
  theme_bw()

ggsave(
  "results/figures/20_coarse-knn-k-sweep.png",
  plot   = coarse_n_neighbors_plot,
  width  = 8,
  height = 5
)

# Fine sweep
best_coarse_k <- coarse_knn_cv_sweep_results |>
  filter(.metric == "j_index") |>
  arrange(desc(mean)) |>
  slice(1) |>
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
  "results/tables/03_fine-knn-cv-results.csv"
)

best_k <- fine_knn_cv_sweep_results |>
  filter(.metric == "j_index") |>
  arrange(desc(mean)) |>
  slice(1) |>
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

dir.create("results/models", recursive = TRUE, showWarnings = FALSE)
saveRDS(knn_stroke_fit, "results/models/knn_fit.rds")

knn_stroke_predictions <- predict(knn_stroke_fit, stroke_validation) |>
  bind_cols(stroke_validation)

knn_model_metrics <- knn_stroke_predictions |>
  metric_set(accuracy, kap, j_index)(
    truth    = stroke,
    estimate = .pred_class
  )

write_csv(knn_model_metrics, "results/tables/04_knn-validation-metrics.csv")

knn_confusion <- knn_stroke_predictions |>
  conf_mat(truth = stroke, estimate = .pred_class)

write_csv(tidy(knn_confusion), "results/tables/05_knn-confusion-matrix.csv")
