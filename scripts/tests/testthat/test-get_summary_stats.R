library(testthat)
library(dplyr)

source("scripts/functions/get_summary_stats.R")

test_that("get_summary_stats works correctly", {
  df <- data.frame(category = c("A", "A", "B"))
  
  result <- get_summary_stats(df, "category")
  
  expect_true(nrow(result) == 2)
})

test_that("get_summary_stats errors on bad input", {
  expect_error(get_summary_stats("not_df", "col"))
})
