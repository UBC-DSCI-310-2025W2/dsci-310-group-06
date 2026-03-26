library(testthat)
library(dplyr)
library(recipes)
library(themis)

# Load the function we are testing
source(here::here("scripts", "functions", "create_stroke_recipe.R"))

# Helper function: creates a small valid training dataset
make_training_data <- function() {
  tibble::tibble(
    stroke = factor(c("Yes", "No", "No", "Yes", "No")),
    gender = factor(c("Male", "Female", "Female", "Male", "Other")),
    age = c(67, 45, 30, 80, 52),
    hypertension = factor(c("Yes", "No", "No", "Yes", "No")),
    heart_disease = factor(c("No", "Yes", "No", "Yes", "No")),
    ever_married = factor(c("Yes", "No", "No", "Yes", "Yes")),
    work_type = factor(c("Private", "Self-employed", "children", "Government", "Private")),
    Residence_type = factor(c("Urban", "Rural", "Urban", "Urban", "Rural")),
    avg_glucose_level = c(228.69, 105.92, 95.12, 171.23, 110.15),
    bmi = c(36.6, 28.1, 22.4, 31.2, 27.8),
    smoking_status = factor(c("Formerly", "Never", "Never", "Smokes", "Formerly"))
  )
}

# Test 1: function returns a recipe object
test_that("create_stroke_recipe() returns a recipe object", {
  training_data <- make_training_data()

  result <- create_stroke_recipe(
    training_data = training_data,
    response = "stroke",
    predictors = c(
      "gender", "age", "hypertension", "heart_disease",
      "ever_married", "work_type", "Residence_type",
      "avg_glucose_level", "bmi", "smoking_status"
    ),
    smote = FALSE
  )

  expect_s3_class(result, "recipe")
})

# Test 2: recipe includes step_smote when smote = TRUE
test_that("create_stroke_recipe() includes SMOTE when smote is TRUE", {
  training_data <- make_training_data()

  result <- create_stroke_recipe(
    training_data = training_data,
    response = "stroke",
    predictors = c(
      "gender", "age", "hypertension", "heart_disease",
      "ever_married", "work_type", "Residence_type",
      "avg_glucose_level", "bmi", "smoking_status"
    ),
    smote = TRUE
  )

  step_classes <- vapply(result$steps, class, character(1))
  expect_true("step_smote" %in% step_classes)
})

# Test 3: recipe does not include step_smote when smote = FALSE
test_that("create_stroke_recipe() does not include SMOTE when smote is FALSE", {
  training_data <- make_training_data()

  result <- create_stroke_recipe(
    training_data = training_data,
    response = "stroke",
    predictors = c(
      "gender", "age", "hypertension", "heart_disease",
      "ever_married", "work_type", "Residence_type",
      "avg_glucose_level", "bmi", "smoking_status"
    ),
    smote = FALSE
  )

  step_classes <- vapply(result$steps, class, character(1))
  expect_false("step_smote" %in% step_classes)
})

# Test 4: recipe includes standard preprocessing steps
test_that("create_stroke_recipe() includes expected preprocessing steps", {
  training_data <- make_training_data()

  result <- create_stroke_recipe(
    training_data = training_data,
    response = "stroke",
    predictors = c(
      "gender", "age", "hypertension", "heart_disease",
      "ever_married", "work_type", "Residence_type",
      "avg_glucose_level", "bmi", "smoking_status"
    ),
    smote = FALSE
  )

  step_classes <- vapply(result$steps, class, character(1))

  expect_true("step_zv" %in% step_classes)
  expect_true("step_dummy" %in% step_classes)
  expect_true("step_normalize" %in% step_classes)
})

# Test 5: error if training_data is not a data frame
test_that("create_stroke_recipe() errors when training_data is not a data frame", {
  expect_error(
    create_stroke_recipe(
      training_data = "not_a_df",
      response = "stroke",
      predictors = c("age", "bmi"),
      smote = FALSE
    ),
    regexp = "`training_data` must be a data frame or tibble\\."
  )
})

# Test 6: error if response is not a single character string
test_that("create_stroke_recipe() errors when response is invalid", {
  training_data <- make_training_data()

  expect_error(
    create_stroke_recipe(
      training_data = training_data,
      response = c("stroke", "other"),
      predictors = c("age", "bmi"),
      smote = FALSE
    ),
    regexp = "`response` must be a single character string\\."
  )
})

# Test 7: error if response is not in training_data
test_that("create_stroke_recipe() errors when response is not a column in training_data", {
  training_data <- make_training_data()

  expect_error(
    create_stroke_recipe(
      training_data = training_data,
      response = "not_a_column",
      predictors = c("age", "bmi"),
      smote = FALSE
    ),
    regexp = "`response` must be a column in `training_data`\\."
  )
})

# Test 8: error if predictors is not a character vector
test_that("create_stroke_recipe() errors when predictors is invalid", {
  training_data <- make_training_data()

  expect_error(
    create_stroke_recipe(
      training_data = training_data,
      response = "stroke",
      predictors = 1:3,
      smote = FALSE
    ),
    regexp = "`predictors` must be a character vector with at least one column name\\."
  )
})

# Test 9: error if predictors are not all in training_data
test_that("create_stroke_recipe() errors when predictors are not columns in training_data", {
  training_data <- make_training_data()

  expect_error(
    create_stroke_recipe(
      training_data = training_data,
      response = "stroke",
      predictors = c("age", "not_a_column"),
      smote = FALSE
    ),
    regexp = "All `predictors` must be columns in `training_data`\\."
  )
})

# Test 10: error if smote is not logical
test_that("create_stroke_recipe() errors when smote is not logical", {
  training_data <- make_training_data()

  expect_error(
    create_stroke_recipe(
      training_data = training_data,
      response = "stroke",
      predictors = c("age", "bmi"),
      smote = "yes"
    ),
    regexp = "`smote` must be TRUE or FALSE\\."
  )
})