library(testthat)
library(dplyr)
library(readr)

source(here::here("scripts", "functions", "evaluate_model.R"))

# dummy data for testing
make_predictions <- function() {
  tibble::tibble(
    stroke      = factor(c("1", "0", "1", "0", "0", "1", "0", "0", "1", "0"),
                         levels = c("0", "1")),
    .pred_class = factor(c("1", "0", "0", "0", "0", "1", "0", "1", "1", "0"),
                         levels = c("0", "1"))
  )
}

# Metric Tests
# Test 1: function returns an invisible list with metrics and matrix

test_that("evaluate_model() returns an invisible list with metrics and confusion_matrix", {
  tmp_metrics <- tempfile(fileext = ".csv")
  tmp_cm      <- tempfile(fileext = ".csv")
  on.exit({ unlink(tmp_metrics); unlink(tmp_cm) })

  result <- evaluate_model(make_predictions(), tmp_metrics, tmp_cm)

  expect_type(result, "list")
  expect_named(result, c("metrics", "confusion_matrix"))
})

# Test 2: function writes the metric csv

test_that("evaluate_model() writes a readable metrics CSV to metric_save_path", {
  tmp_metrics <- tempfile(fileext = ".csv")
  tmp_cm      <- tempfile(fileext = ".csv")
  on.exit({ unlink(tmp_metrics); unlink(tmp_cm) })

  evaluate_model(make_predictions(), tmp_metrics, tmp_cm)

  expect_true(file.exists(tmp_metrics))
  metrics <- read_csv(tmp_metrics, show_col_types = FALSE)
  expect_s3_class(metrics, "data.frame")
})

# Test 3: metrics output contain required metrics

test_that("evaluate_model() metrics CSV contains j_index, sensitivity, and specificity", {
  tmp_metrics <- tempfile(fileext = ".csv")
  tmp_cm      <- tempfile(fileext = ".csv")
  on.exit({ unlink(tmp_metrics); unlink(tmp_cm) })

  evaluate_model(make_predictions(), tmp_metrics, tmp_cm)

  metrics <- read_csv(tmp_metrics, show_col_types = FALSE)
  expect_true(all(c("j_index", "sensitivity", "specificity") %in% metrics$.metric))
})

# Test 4: metrics contain required columns
test_that("evaluate_model() metrics tibble has .metric and .estimate columns", {
  tmp_metrics <- tempfile(fileext = ".csv")
  tmp_cm      <- tempfile(fileext = ".csv")
  on.exit({ unlink(tmp_metrics); unlink(tmp_cm) })

  result <- evaluate_model(make_predictions(), tmp_metrics, tmp_cm)

  expect_true(all(c(".metric", ".estimate") %in% names(result$metrics)))
})

# Confusion Matrix

# Test 1: function writes the confusion matrix csv
test_that("evaluate_model() writes a readable confusion matrix CSV to confusion_save_path", {
  tmp_metrics <- tempfile(fileext = ".csv")
  tmp_cm      <- tempfile(fileext = ".csv")
  on.exit({ unlink(tmp_metrics); unlink(tmp_cm) })

  evaluate_model(make_predictions(), tmp_metrics, tmp_cm)

  expect_true(file.exists(tmp_cm))
  cm <- read_csv(tmp_cm, show_col_types = FALSE)
  expect_s3_class(cm, "data.frame")
})

# Test 2: confusion matrix output is correct in setup
test_that("evaluate_model() confusion matrix CSV has Prediction, Truth, and n columns", {
  tmp_metrics <- tempfile(fileext = ".csv")
  tmp_cm      <- tempfile(fileext = ".csv")
  on.exit({ unlink(tmp_metrics); unlink(tmp_cm) })

  evaluate_model(make_predictions(), tmp_metrics, tmp_cm)

  cm <- read_csv(tmp_cm, show_col_types = FALSE)
  expect_true(all(c("Prediction", "Truth", "n") %in% names(cm)))
})

# not going to test the actual values of the metrics or confusion matrix 
# since we aren't calculating those with our code

# Input validation tests

# Test 1: throw error if not data frame
test_that("evaluate_model() errors when predictions is not a data frame", {
  tmp_metrics <- tempfile(fileext = ".csv")
  tmp_cm      <- tempfile(fileext = ".csv")
  on.exit({ unlink(tmp_metrics); unlink(tmp_cm) })

  expect_error(
    evaluate_model("not_a_df", tmp_metrics, tmp_cm),
    regexp = "`predictions` must be a data frame or tibble\\."
  )
})


# Test 2: throw error if .pred_class column is missing
test_that("evaluate_model() errors when .pred_class column is missing", {
  tmp_metrics <- tempfile(fileext = ".csv")
  tmp_cm      <- tempfile(fileext = ".csv")
  on.exit({ unlink(tmp_metrics); unlink(tmp_cm) })

  bad_preds <- make_predictions() |> select(-`.pred_class`)

  expect_error(
    evaluate_model(bad_preds, tmp_metrics, tmp_cm),
    regexp = "`predictions` must contain a `\\.pred_class` column\\."
  )
})

# Test 3: throw error if stroke column is missing
test_that("evaluate_model() errors when stroke column is missing", {
  tmp_metrics <- tempfile(fileext = ".csv")
  tmp_cm      <- tempfile(fileext = ".csv")
  on.exit({ unlink(tmp_metrics); unlink(tmp_cm) })

  bad_preds <- make_predictions() |> select(-stroke)

  expect_error(
    evaluate_model(bad_preds, tmp_metrics, tmp_cm),
    regexp = "`predictions` must contain a `stroke` column\\."
  )
})

# Test 4: throw error if metric_save_path directory does not exist
test_that("evaluate_model() errors when metric_save_path directory does not exist", {
  tmp_cm <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp_cm))

  expect_error(
    evaluate_model(make_predictions(), "/nonexistent/dir/metrics.csv", tmp_cm),
    regexp = "Directory does not exist:"
  )
})

# Test 5: throw error if confusion_save_path directory does not exist
test_that("evaluate_model() errors when confusion_save_path directory does not exist", {
  tmp_metrics <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp_metrics))

  expect_error(
    evaluate_model(make_predictions(), tmp_metrics, "/nonexistent/dir/cm.csv"),
    regexp = "Directory does not exist:"
  )
})
