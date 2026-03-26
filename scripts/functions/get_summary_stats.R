#' Get summary statistics for a categorical column
#'
#' Computes counts of each unique value in a specified column of a data frame.
#'
#' @param df A data frame
#' @param column A column name (string)
#' @param coerce.char Logical, whether to convert column to character
#' @param new.key Name for the output column
#'
#' @return A data frame with counts for each category
#'
#' @examples
#' df <- data.frame(category = c("A", "A", "B"))
#' get_summary_stats(df, "category")
#'
#' @export

library(dplyr) 

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
