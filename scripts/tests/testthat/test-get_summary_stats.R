library(testthat)
library(dplyr)
library(here)

source(here::here("scripts", "functions", "get_summary_stats.R"))

test_that("get_summary_stats works correctly", {
  df <- data.frame(category = c("A", "A", "B"))

  result <- get_summary_stats(df, "category")

  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 2)

  # Check counts exist
  expect_true("n" %in% names(result))
})

test_that("get_summary_stats counts are correct", {
  df <- data.frame(category = c("A", "A", "B", "B", "B"))

  result <- get_summary_stats(df, "category")

  # Sort safely using first column (not assuming name)
  result <- result %>% arrange(result[[1]])

  expect_equal(result$n, c(2, 3))
})

test_that("get_summary_stats coerce.char works", {
  df <- data.frame(category = c(1, 1, 2))

  result <- get_summary_stats(df, "category", coerce.char = TRUE)

  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 2)
})

test_that("get_summary_stats errors on bad input", {
  expect_error(get_summary_stats("not_df", "category"))
})

test_that("get_summary_stats errors if column missing", {
  df <- data.frame(a = c(1, 2, 3))
  expect_error(get_summary_stats(df, "category"))
})
