library(testthat)
library(dplyr)
library(readr)

# Load the function we are testing
source(here::here("scripts", "functions", "load_stroke_data.R"))

# Helper function: creates a small valid stroke dataset and writes to CSV
make_stroke_csv <- function(path) {
  test_data <- tibble::tibble(
    id = 1:3,
    gender = c("Male", "Female", "Other"),
    age = c(67, 45, 30),
    hypertension = c(1, 0, 0),
    heart_disease = c(0, 1, 0),
    ever_married = c("Yes", "No", "No"),
    work_type = c("Private", "Self-employed", "children"),
    Residence_type = c("Urban", "Rural", "Urban"),
    avg_glucose_level = c(228.69, 105.92, 95.12),
    bmi = c("36.6", "N/A", "22.4"),
    smoking_status = c("formerly smoked", "never smoked", "Unknown"),
    stroke = c(1, 0, 0)
  )

  readr::write_csv(test_data, path)
}

# Test 1: Function loads data and returns a tibble
test_that("load_stroke_data() loads dataset and returns tibble", {
  tmp_file <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp_file))  # clean up temp file after test

  make_stroke_csv(tmp_file)
  data <- load_stroke_data(tmp_file)

  expect_s3_class(data, "tbl_df")
})

# Test 2: All required columns are present
test_that("load_stroke_data() contains all required columns", {
  tmp_file <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp_file))

  make_stroke_csv(tmp_file)
  data <- load_stroke_data(tmp_file)

  required_cols <- c(
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

  expect_true(all(required_cols %in% names(data)))
})

# Test 3: Categorical variables are converted to factors
test_that("load_stroke_data() converts categorical columns to factors", {
  tmp_file <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp_file))

  make_stroke_csv(tmp_file)
  data <- load_stroke_data(tmp_file)

  expect_true(is.factor(data$gender))
  expect_true(is.factor(data$hypertension))
  expect_true(is.factor(data$heart_disease))
  expect_true(is.factor(data$ever_married))
  expect_true(is.factor(data$work_type))
  expect_true(is.factor(data$Residence_type))
  expect_true(is.factor(data$smoking_status))
  expect_true(is.factor(data$stroke))
})

# Test 4: Function throws error if file does not exist
test_that("load_stroke_data() errors when file does not exist", {
  expect_error(
    load_stroke_data("data/does_not_exist.csv"),
    regexp = "File does not exist"
  )
})

# Test 5: Function throws error if required columns are missing
test_that("load_stroke_data() errors when required columns are missing", {
  tmp_file <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp_file))

  # Create an invalid dataset missing required columns
  bad_data <- tibble::tibble(
    id = 1:3,
    gender = c("Male", "Female", "Male"),
    age = c(25, 40, 60)
  )

  readr::write_csv(bad_data, tmp_file)

  expect_error(
    load_stroke_data(tmp_file),
    regexp = "missing required columns"
  )
})

# Test 6: Function throws error if data_path is not a character string
test_that("load_stroke_data() errors when data_path is not a character string", {
  expect_error(
    load_stroke_data(123),
    regexp = "`data_path` must be a single character string\\."
  )
})