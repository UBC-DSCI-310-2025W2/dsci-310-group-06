library(testthat)
library(dplyr)
library(here)

# Load the function
source(here::here("scripts", "functions", "get_summary_stats.R"))

test_that("get_summary_stats works correctly", {
  
  df <- data.frame(category = c("A", "A", "B"))
  
  result <- get_summary_stats(df, "category")
  
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 2)
  
  # Check counts
  expect_true(all(c("A", "B") %in% result$category))
})

test_that("get_summary_stats counts are correct", {
  
  df <- data.frame(category = c("A", "A", "B", "B", "B"))
  
  result <- get_summary_stats(df, "category")
  
  counts <- result %>% arrange(category)
  
  expect_equal(counts$n, c(2, 3))
})

test_that("get_summary_stats errors on bad input", {
  
  expect_error(get_summary_stats("not_df", "category"))
})

test_that("get_summary_stats errors if column missing", {
  
  df <- data.frame(a = c(1, 2, 3))
  
  expect_error(get_summary_stats(df, "category"))
})
