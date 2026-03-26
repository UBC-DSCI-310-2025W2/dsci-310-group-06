select_best_params <- function(cv_results) {

  if (!is.data.frame(cv_results)) {
    stop("`cv_results` must be a data frame.")}

  if (!(".metric" %in% names(cv_results))) {
    stop("`cv_results` must contain a `.metric` column.")}

  if (!("mean" %in% names(cv_results))) {
    stop("`cv_results` must contain a `mean` column.")}

  best_params <- cv_results |>
    dplyr::filter(.metric == "j_index") |>
    dplyr::arrange(desc(mean)) |>
    dplyr::slice(1)

  return(best_params)}
