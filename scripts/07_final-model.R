source("renv/activate.R")
source("scripts/functions/evaluate_model.R")
source("scripts/functions/select_best_params.R")
source("scripts/functions/plot_confusion_matrix.R")
source("scripts/functions/set_plot_theme.R")
set_plot_theme()

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

# Figure 25: Validation metrics comparison bar chart
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
    title = "Validation Set Metrics by Model",
    x     = "Metric",
    y     = "Estimate",
    fill  = "Model"
  )

ggsave(
  "results/figures/25_validation-metrics-comparison.png",
  plot   = metrics_plot,
  width  = 8,
  height = 5
)

# Figure 26: Confusion matrices on validation set
knn_cm_plot <- plot_confusion_matrix(
  "results/tables/05_knn-confusion-matrix.csv", "kNN"
)
logr_cm_plot <- plot_confusion_matrix(
  "results/tables/09_logreg-confusion-matrix.csv", "Logistic Regression"
)

xgb_cm_plot <- plot_confusion_matrix(
  "results/tables/12_xgboost-confusion-matrix.csv", "XGBoost" 
)

confusion_grid <- gridExtra::arrangeGrob(
  knn_cm_plot, logr_cm_plot, xgb_cm_plot,
  ncol = 3,
  top  = grid::textGrob("Confusion Matrices on Validation Set", gp = grid::gpar(fontsize = 11))
)

ggplot2::ggsave(
  filename = "results/figures/26_validation-confusion-matrices.png",
  plot     = confusion_grid,
  width    = 12, # Wider to fit 3 plots side-by-side
  height   = 4
)

# Select best model
best_model_name <- all_val_metrics |>
  rename(mean = .estimate) |>
  select_best_params() |>
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

final_test_results <- evaluate_model(
  predictions         = final_test_predictions,
  metric_save_path    = "results/tables/14_final-model-test-metrics.csv",
  confusion_save_path = "results/tables/15_final-model-test-confusion-matrix.csv"
)

final_test_metrics <- final_test_results$metrics |>
  mutate(model = best_model_name)

write_csv(final_test_metrics, "results/tables/14_final-model-test-metrics.csv")

# Figure 27: Final model test set confusion matrix
final_test_confusion <- yardstick::conf_mat(
  final_test_predictions,
  truth    = stroke,
  estimate = .pred_class
)

final_cm_plot <- plot_confusion_matrix(
  confusion_save_path = "results/tables/15_final-model-test-confusion-matrix.csv",
  title = paste0(best_model_name, " Confusion Matrix on Test Set")
)

ggsave(
  "results/figures/27_final-model-test-confusion.png",
  plot   = final_cm_plot,
  width  = 6,
  height = 5
)
