#' Load and validate stroke dataset
#'
#' @description
#' Given a CSV file containing the stroke dataset, reads the data, checks that
#' all required columns are present, and converts the categorical columns to
#' factors.
#'
#' @param data_path Character. File path to the CSV containing the stroke
#'   dataset.
#'
#' @return A tibble containing the validated stroke dataset, with categorical
#'   columns converted to factors.
#'
#' @examples
#' \dontrun{
#' stroke_data <- load_stroke_data(
#'   data_path = "data/raw/healthcare-dataset-stroke-data.csv"
#' )
#' }
load_stroke_data <- function(data_path) {
  if (!is.character(data_path) || length(data_path) != 1) {
    stop("`data_path` must be a single character string.")
  }

  if (!file.exists(data_path)) {
    stop("File does not exist: ", data_path)
  }

  stroke_data <- readr::read_csv(data_path, show_col_types = FALSE)

  required_columns <- c(
    "id",
    "gender",
    "age",
    "hypertension",
    "heart_disease",
    "ever_married",
    "work_type",
    "Residence_type",
    "avg_glucose_level",
    "bmi",
    "smoking_status",
    "stroke"
  )

  missing_columns <- setdiff(required_columns, names(stroke_data))

  if (length(missing_columns) > 0) {
    stop(
      "The dataset is missing required columns: ",
      paste(missing_columns, collapse = ", ")
    )
  }

  factor_columns <- c(
    "gender",
    "hypertension",
    "heart_disease",
    "ever_married",
    "work_type",
    "Residence_type",
    "smoking_status",
    "stroke"
  )

  stroke_data <- dplyr::mutate(
    stroke_data,
    dplyr::across(dplyr::all_of(factor_columns), as.factor)
  )

  stroke_data
}