library(testthat)
library(dplyr)
library(readr)

source(here::here("scripts", "functions", "load_stroke_data.R"))

# Test 1: function loads data correctly
test_that("load_stroke_data() loads dataset and returns tibble", {
  data <- load_stroke_data(here::here("data", "healthcare-dataset-stroke-data.csv"))

  expect_s3_class(data, "tbl_df")
})

# Test 2: required columns exist
test_that("load_stroke_data() contains all required columns", {
  data <- load_stroke_data(here::here("data", "healthcare-dataset-stroke-data.csv"))

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

# Test 3: categorical variables are factors
test_that("load_stroke_data() converts categorical columns to factors", {
  data <- load_stroke_data(here::here("data", "healthcare-dataset-stroke-data.csv"))

  expect_true(is.factor(data$gender))
  expect_true(is.factor(data$hypertension))
  expect_true(is.factor(data$heart_disease))
  expect_true(is.factor(data$ever_married))
  expect_true(is.factor(data$work_type))
  expect_true(is.factor(data$Residence_type))
  expect_true(is.factor(data$smoking_status))
  expect_true(is.factor(data$stroke))
})

# Test 4: error if file does not exist
test_that("load_stroke_data() errors when file does not exist", {
  expect_error(
    load_stroke_data("data/does_not_exist.csv"),
    regexp = "File does not exist"
  )
})

# Test 5: error if required columns missing
test_that("load_stroke_data() errors when required columns are missing", {
  tmp_file <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp_file))

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