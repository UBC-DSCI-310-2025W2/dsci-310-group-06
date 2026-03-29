#' Create a preprocessing recipe for stroke model training
#'
#' @description
#' Given training data, a response variable, a set of predictor variables, and
#' whether to include SMOTE, creates a recipe that can be used to train stroke
#' classification models. The recipe removes zero-variance predictors, creates
#' dummy variables for nominal predictors, normalizes numeric predictors, and
#' optionally applies SMOTE to address class imbalance.
#'
#' @param training_data A data frame or tibble containing the training data.
#' @param response Character. Name of the response variable column.
#' @param predictors Character vector. Names of predictor variable columns.
#' @param smote Logical. Whether to include `themis::step_smote()` in the
#'   recipe.
#'
#' @return A `recipes::recipe` object for preprocessing stroke model data.
#'
#' @examples
#' \dontrun{
#' stroke_recipe <- create_stroke_recipe(
#'   training_data = stroke_training,
#'   response      = "stroke",
#'   predictors    = c(
#'     "gender", "age", "hypertension", "heart_disease",
#'     "ever_married", "work_type", "Residence_type",
#'     "avg_glucose_level", "bmi", "smoking_status"
#'   ),
#'   smote = TRUE
#' )
#' }
create_stroke_recipe <- function(training_data, response, predictors, smote) {
  if (!is.data.frame(training_data)) {
    stop("`training_data` must be a data frame or tibble.")
  }
  if (!is.character(response) || length(response) != 1) {
    stop("`response` must be a single character string.")
  }
  if (!response %in% names(training_data)) {
    stop("`response` must be a column in `training_data`.")
  }
  if (!is.character(predictors) || length(predictors) < 1) {
    stop("`predictors` must be a character vector with at least one column name.")
  }
  if (!all(predictors %in% names(training_data))) {
    stop("All `predictors` must be columns in `training_data`.")
  }
  if (!is.logical(smote) || length(smote) != 1) {
    stop("`smote` must be TRUE or FALSE.")
  }

  recipe_formula <- stats::as.formula(
    paste(response, "~", paste(predictors, collapse = " + "))
  )

  stroke_recipe <- recipes::recipe(recipe_formula, data = training_data) |>
  recipes::step_zv(recipes::all_predictors()) |>
  recipes::step_YeoJohnson(recipes::all_numeric_predictors()) |>
  recipes::step_scale(recipes::all_numeric_predictors()) |>
  recipes::step_center(recipes::all_numeric_predictors()) |>
  recipes::step_dummy(recipes::all_nominal_predictors())

  if (smote) {
    stroke_recipe <- stroke_recipe |>
      themis::step_smote(recipes::all_outcomes())
  }

  stroke_recipe
}