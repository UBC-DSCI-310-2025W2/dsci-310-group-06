source("renv/activate.R")

library(tidyverse)
library(tidymodels)
library(gridExtra)
library(grid)

set.seed(894235)

# Load test data
factor_cols <- c(
  "gender", "work_type", "residence_type", "smoking_status",
  "hypertension", "ever_married", "heart_disease", "stroke"
)

stroke_testing <- read_csv("data/processed/stroke_testing.csv") |>
  mutate(across(all_of(factor_cols), factor))

plot_theme <- theme_bw(base_size = 11) +
  theme(
    plot.title   = element_text(hjust = 0.5, size = 12),
    axis.text.x  = element_text(size = 9),
    axis.text.y  = element_text(size = 9),
    axis.title.x = element_text(size = 10),
    axis.title.y = element_text(size = 10),
    legend.title = element_text(size = 10),
    legend.text  = element_text(size = 9),
    strip.text   = element_text(size = 9)
  )

# Load validation metric csvs
all_val_metrics <- bind_rows(
  read_csv("results/tables/04_knn-validation-metrics.csv") |>
    mutate(model = "kNN"),
  read_csv("results/tables/08_logreg-validation-metrics.csv") |>
    mutate(model = "Logistic Regression"),
  read_csv("results/tables/11_xgboost-validation-metrics.csv") |>
    mutate(model = "XGBoost")
)

write_csv(all_val_metrics, "results/tables/13_all-validation-metrics.csv")

# Figure 22: Validation metrics comparison bar chart
metrics_plot <- all_val_metrics |>
  mutate(
    .metric = recode(.metric,
      "j_index"     = "J-Index",
      "sensitivity" = "Sensitivity",
      "accuracy"    = "Accuracy",
      "kap"         = "Kappa"
    ),
    model = factor(model, levels = c("kNN", "Logistic Regression", "XGBoost"))
  ) |>
  ggplot(aes(x = .metric, y = .estimate, fill = model)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6) +
  scale_fill_brewer(palette = "Set2") +
  labs(
    title = "Figure 22. Validation Set Metrics by Model",
    x     = "Metric",
    y     = "Estimate",
    fill  = "Model"
  ) +
  plot_theme

ggsave(
  "results/figures/22_validation-metrics-comparison.png",
  plot   = metrics_plot,
  width  = 8,
  height = 5
)

# Figure 23: Confusion matrices on validation set
make_cm_plot <- function(csv_path, title) {
  read_csv(csv_path) |>
    mutate(across(c(Prediction, Truth), factor)) |>
    ggplot(aes(x = Prediction, y = Truth, fill = n)) +
    geom_tile() +
    geom_text(aes(label = n), size = 5) +
    scale_fill_gradient(low = "white", high = "#4393C3") +
    labs(title = title) +
    plot_theme +
    theme(legend.position = "none")
}

knn_cm_plot <- make_cm_plot(
  "results/tables/05_knn-confusion-matrix.csv", "kNN"
)
logr_cm_plot <- make_cm_plot(
  "results/tables/09_logreg-confusion-matrix.csv", "Logistic Regression"
)
xgb_cm_plot <- make_cm_plot(
  "results/tables/12_xgboost-confusion-matrix.csv", "XGBoost"
)

confusion_grid <- gridExtra::arrangeGrob(
  knn_cm_plot, logr_cm_plot, xgb_cm_plot,
  ncol = 3,
  top  = grid::textGrob(
    "Figure 23. Confusion Matrices on Validation Set",
    gp = grid::gpar(fontsize = 11)
  )
)

ggsave(
  "results/figures/23_validation-confusion-matrices.png",
  plot   = confusion_grid,
  width  = 12,
  height = 4
)

# Select best model
best_model_name <- all_val_metrics |>
  filter(.metric == "j_index") |>
  arrange(desc(.estimate)) |>
  slice(1) |>
  pull(model)

best_fit_path <- list(
  "kNN"                 = "results/models/knn_fit.rds",
  "Logistic Regression" = "results/models/logr_fit.rds",
  "XGBoost"             = "results/models/xgb_fit.rds"
)[[best_model_name]]

best_fit <- readRDS(best_fit_path)

# Evaluate final model on testing set
final_test_predictions <- predict(best_fit, stroke_testing) |>
  bind_cols(stroke_testing)

final_test_metrics <- final_test_predictions |>
  metric_set(j_index, sensitivity, specificity, accuracy)(
    truth    = stroke,
    estimate = .pred_class
  ) |>
  mutate(model = best_model_name)

write_csv(final_test_metrics, "results/tables/14_final-model-test-metrics.csv")

final_test_confusion <- final_test_predictions |>
  conf_mat(truth = stroke, estimate = .pred_class)

write_csv(
  as_tibble(final_test_confusion$table),
  "results/tables/15_final-model-test-confusion-matrix.csv"
)

# Figure 24: Final model test set confusion matrix
final_cm_plot <- autoplot(final_test_confusion, type = "heatmap") +
  labs(title = paste0("Figure 24. ", best_model_name, " Confusion Matrix on Test Set")) +
  plot_theme

ggsave(
  "results/figures/24_final-model-test-confusion.png",
  plot   = final_cm_plot,
  width  = 6,
  height = 5
)
