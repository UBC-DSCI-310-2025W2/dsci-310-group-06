library(testthat)
library(ggplot2)
library(readr)

source(here::here("scripts", "functions", "plot_confusion_matrix.R"))

# Helper to create a dummy CSV for testing
make_dummy_cm_csv <- function(path) {
  tibble::tibble(
    Prediction = factor(c("0", "0", "1", "1"), levels = c("0", "1")),
    Truth = factor(c("0", "1", "0", "1"), levels = c("0", "1")),
    n = c(10, 2, 1, 5)
  ) |> readr::write_csv(path)
}

# --- Plot Output Tests ---

# Test 1: function returns a ggplot object
test_that("plot_confusion_matrix() returns a ggplot object", {
  tmp_cm <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp_cm))
  make_dummy_cm_csv(tmp_cm)
  
  result <- plot_confusion_matrix(tmp_cm, "Test Title")
  
  expect_s3_class(result, "ggplot")
  expect_s3_class(result, "gg")
})

# Test 2: plot contains the correct title
test_that("plot_confusion_matrix() uses the provided title in the plot labels", {
  tmp_cm <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp_cm))
  make_dummy_cm_csv(tmp_cm)
  
  test_title <- "Stroke Prediction Confusion Matrix"
  result <- plot_confusion_matrix(tmp_cm, test_title)
  
  expect_equal(result$labels$title, test_title)
})

# --- Visual Mapping Tests ---

# Test 1: plot uses correct aesthetic mapping for Prediction, Truth, and n
test_that("plot_confusion_matrix() maps Prediction to x, Truth to y, and label to display_text", {
  tmp_cm <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp_cm))
  make_dummy_cm_csv(tmp_cm)
  
  result <- plot_confusion_matrix(tmp_cm, "Test Title")
  
  expect_equal(rlang::as_name(result$mapping$x), "Prediction")
  expect_equal(rlang::as_name(result$mapping$y), "Truth")
  
  # Look for "display_text" instead of "n"
  label_mapping <- rlang::as_name(result$layers[[2]]$mapping$label)
  expect_equal(label_mapping, "display_text")
})

# --- Input Validation Tests ---

# Test 1: throw error if CSV is missing required columns
test_that("plot_confusion_matrix() errors when CSV is missing required columns", {
  tmp_cm <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp_cm))
  
  # Create a bad CSV missing the 'n' column
  tibble::tibble(
    Prediction = c("0", "1"),
    Truth = c("0", "1")
  ) |> readr::write_csv(tmp_cm)
  
  expect_error(
    plot_confusion_matrix(tmp_cm, "Title"),
    regexp = "CSV must contain 'Prediction', 'Truth', and 'n' columns\\."
  )
})

# Test 2: throw error if file path does not exist
test_that("plot_confusion_matrix() errors when the file path is invalid", {
  expect_error(
    plot_confusion_matrix("nonexistent_path/cm_results.csv", "Title")
  )
})

# --- Edge Case Test ---

test_that("plot_confusion_matrix() handles a CSV with zero rows (empty results)", {
  tmp_cm <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp_cm))
  
  # Create a valid header but no data
  tibble::tibble(
    Prediction = character(),
    Truth = character(),
    n = numeric()
  ) |> readr::write_csv(tmp_cm)
  
  # The function should still return a ggplot object without erroring
  result <- plot_confusion_matrix(tmp_cm, "Empty Test")
  
  expect_s3_class(result, "ggplot")
  # Check if the data inside the plot has 0 rows
  expect_equal(nrow(result$data), 0)
})