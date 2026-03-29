#' Select best parameters based on j-index
#'
#' Given cross-validation results, selects the row with the highest j-index.
#'
#' @param cv_results A data frame containing cross-validation results
#' @return A data frame row with the best parameters
#' @export

select_best_params <- function(cv_results) {

  if (!is.data.frame(cv_results)) {
    stop("`cv_results` must be a data frame.")
  }

  if (!(".metric" %in% names(cv_results))) {
    stop("`cv_results` must contain a `.metric` column.")
  }

  if (!("mean" %in% names(cv_results))) {
    stop("`cv_results` must contain a `mean` column.")
  }

  if (!("j_index" %in% cv_results$.metric)) {
    stop("No j_index metric found.")
  }

  best_params <- cv_results |>
    dplyr::filter(.metric == "j_index") |>
    dplyr::arrange(dplyr::desc(mean)) |>
    dplyr::slice(1)

  return(best_params)
}
