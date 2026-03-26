#' Get summary statistics for a categorical variable
#'
#' @param df A data frame
#' @param column Column name (string)
#' @param coerce.char Logical, whether to convert column to character
#' @param new.key Name for the output column
#'
#' @return A data frame with counts for each category
#' @export

get_summary_stats <- function(df, column, coerce.char = FALSE, new.key = column) {
  
  if (!is.data.frame(df)) {
    stop("`df` must be a data frame.")}
  
  if (!(column %in% names(df))) {
    stop("Column not found in dataframe.")}
  
  data <- df
  
  if (coerce.char) {
    data[[column]] <- as.character(data[[column]])}
  
  summary <- data |>
    dplyr::group_by(.data[[column]]) |>
    dplyr::summarise(value = dplyr::n(), .groups = "drop") |>
    dplyr::rename(key = 1) |>
    dplyr::mutate(column_name = new.key)
  
  return(summary)}
