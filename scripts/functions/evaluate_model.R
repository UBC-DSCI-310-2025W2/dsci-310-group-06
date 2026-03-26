#' Evaluate model predictions and save results to CSV files
#'
#' @description
#' Given a tibble of model predictions, computes j_index, sensitivity, and
#' specificity, writes the metrics to a CSV at `metric_save_path`, and writes
#' a tidied confusion matrix to a CSV at `confusion_save_path`.
#'
#' @param predictions A data frame or tibble containing at minimum a
#'   `.pred_class` column (factor of predicted classes) and a `stroke` column
#'   (factor of true classes), as produced by `predict()` bound with the
#'   original data via `bind_cols()`.
#' @param metric_save_path Character. File path where the metrics CSV will be
#'   written. The parent directory must already exist.
#' @param confusion_save_path Character. File path where the confusion matrix
#'   CSV will be written. The parent directory must already exist.
#'
#' @return Invisibly returns a named list with two elements:
#'   \describe{
#'     \item{metrics}{A tibble with columns `.metric`, `.estimator`,
#'       `.estimate` containing j_index, sensitivity, and specificity.}
#'     \item{confusion_matrix}{A tibble with columns `Prediction`, `Truth`,
#'       and `n` representing the tidied confusion matrix.}
#'   }
#'
#' @examples
#' \dontrun{
#' predictions <- predict(knn_fit, stroke_validation) |>
#'   dplyr::bind_cols(stroke_validation)
#'
#' evaluate_model(
#'   predictions         = predictions,
#'   metric_save_path    = "results/tables/04_knn-validation-metrics.csv",
#'   confusion_save_path = "results/tables/05_knn-confusion-matrix.csv"
#' )
#' }
evaluate_model <- function(predictions, metric_save_path, confusion_save_path) {
  if (!is.data.frame(predictions)) {
    stop("`predictions` must be a data frame or tibble.")
  }
  if (!".pred_class" %in% names(predictions)) {
    stop("`predictions` must contain a `.pred_class` column.")
  }
  if (!"stroke" %in% names(predictions)) {
    stop("`predictions` must contain a `stroke` column.")
  }
  if (!dir.exists(dirname(metric_save_path))) {
    stop(paste0("Directory does not exist: ", dirname(metric_save_path)))
  }
  if (!dir.exists(dirname(confusion_save_path))) {
    stop(paste0("Directory does not exist: ", dirname(confusion_save_path)))
  }

  metrics <- yardstick::metric_set(
    yardstick::j_index,
    yardstick::sensitivity,
    yardstick::specificity
  )(
    predictions,
    truth    = stroke,
    estimate = .pred_class
  )

  readr::write_csv(metrics, metric_save_path)

  cm <- yardstick::conf_mat(predictions, truth = stroke, estimate = .pred_class)
  cm_tbl <- dplyr::as_tibble(cm$table)

  readr::write_csv(cm_tbl, confusion_save_path)

  invisible(list(metrics = metrics, confusion_matrix = cm_tbl))
}
