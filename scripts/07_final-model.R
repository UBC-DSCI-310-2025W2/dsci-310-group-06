source("renv/activate.R")
source("scripts/functions/evaluate_model.R")
source("scripts/functions/select_best_params.R")
source("scripts/functions/plot_confusion_matrix.R")
source("scripts/functions/set_plot_theme.R")
set_plot_theme()

library(docopt)
library(tidyverse)
library(tidymodels)
library(gridExtra)
library(grid)

set.seed(894235)

doc <- "
Usage: 07_final-model.R --testing=<path> --knn_metrics=<path> --logreg_metrics=<path> --xgb_metrics=<path> --knn_cm=<path> --logreg_cm=<path> --xgb_cm=<path> --knn_model=<path> --logreg_model=<path> --xgb_model=<path> --out_figures_dir=<dir> --out_tables_dir=<dir>

Options:
  --testing=<path>          Path to testing CSV
  --knn_metrics=<path>      Path to kNN validation metrics CSV
  --logreg_metrics=<path>   Path to logistic regression validation metrics CSV
  --xgb_metrics=<path>      Path to XGBoost validation metrics CSV
  --knn_cm=<path>           Path to kNN confusion matrix CSV
  --logreg_cm=<path>        Path to logistic regression confusion matrix CSV
  --xgb_cm=<path>           Path to XGBoost confusion matrix CSV
  --knn_model=<path>        Path to kNN model RDS
  --logreg_model=<path>     Path to logistic regression model RDS
  --xgb_model=<path>        Path to XGBoost model RDS
  --out_figures_dir=<dir>   Directory for output figures
  --out_tables_dir=<dir>    Directory for output tables
"

opts            <- docopt(doc)
testing_path    <- opts$testing
knn_metrics     <- opts$knn_metrics
logreg_metrics  <- opts$logreg_metrics
xgb_metrics     <- opts$xgb_metrics
knn_cm          <- opts$knn_cm
logreg_cm       <- opts$logreg_cm
xgb_cm          <- opts$xgb_cm
knn_model       <- opts$knn_model
logreg_model    <- opts$logreg_model
xgb_model       <- opts$xgb_model
out_figures_dir <- opts$out_figures_dir
out_tables_dir  <- opts$out_tables_dir

dir.create(out_figures_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(out_tables_dir,  recursive = TRUE, showWarnings = FALSE)

# Load test data
factor_cols <- c(
  "gender", "work_type", "residence_type", "smoking_status",
  "hypertension", "ever_married", "heart_disease", "stroke"
)

stroke_testing <- read_csv(testing_path) |>
  mutate(across(all_of(factor_cols), factor))

# Load validation metric csvs
all_val_metrics <- bind_rows(
  read_csv(knn_metrics) |>
    mutate(model = "kNN"),
  read_csv(logreg_metrics) |>
    mutate(model = "Logistic Regression"),
  read_csv(xgb_metrics) |>
    mutate(model = "XGBoost")
)

write_csv(all_val_metrics, file.path(out_tables_dir, "13_all-validation-metrics.csv"))

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
  file.path(out_figures_dir, "22_validation-metrics-comparison.png"),
  plot   = metrics_plot,
  width  = 8,
  height = 5
)

# Figure 23: Confusion matrices on validation set
knn_cm_plot <- plot_confusion_matrix(
  knn_cm, "kNN"
)
logr_cm_plot <- plot_confusion_matrix(
  logreg_cm, "Logistic Regression"
)

xgb_cm_plot <- plot_confusion_matrix(
  xgb_cm, "XGBoost"
)

confusion_grid <- gridExtra::arrangeGrob(
  knn_cm_plot, logr_cm_plot, xgb_cm_plot,
  ncol = 3,
  top  = grid::textGrob("Confusion Matrices on Validation Set", gp = grid::gpar(fontsize = 11))
)

ggplot2::ggsave(
  filename = file.path(out_figures_dir, "23_validation-confusion-matrices.png"),
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
  "kNN"                 = knn_model,
  "Logistic Regression" = logreg_model,
  "XGBoost"             = xgb_model
)[[best_model_name]]

best_fit <- readRDS(best_fit_path)

# Evaluate final model on testing set
final_test_predictions <- predict(best_fit, stroke_testing) |>
  bind_cols(stroke_testing)

final_test_results <- evaluate_model(
  predictions         = final_test_predictions,
  metric_save_path    = file.path(out_tables_dir, "14_final-model-test-metrics.csv"),
  confusion_save_path = file.path(out_tables_dir, "15_final-model-test-confusion-matrix.csv")
)

final_test_metrics <- final_test_results$metrics |>
  mutate(model = best_model_name)

write_csv(final_test_metrics, file.path(out_tables_dir, "14_final-model-test-metrics.csv"))

# Figure 27: Final model test set confusion matrix
final_test_confusion <- yardstick::conf_mat(
  final_test_predictions,
  truth    = stroke,
  estimate = .pred_class
)

final_cm_plot <- plot_confusion_matrix(
  confusion_save_path = file.path(out_tables_dir, "15_final-model-test-confusion-matrix.csv"),
  title = paste0(best_model_name, " Confusion Matrix on Test Set")
)

ggsave(
  file.path(out_figures_dir, "24_final-model-test-confusion.png"),
  plot   = final_cm_plot,
  width  = 6,
  height = 5
)
