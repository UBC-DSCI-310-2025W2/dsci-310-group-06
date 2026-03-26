library(testthat)
library(dplyr)

source("../functions/select_best_params.R")

test_that("select_best_params works correctly", {

  df <- data.frame(
    .metric = c("j_index", "j_index", "accuracy"),
    mean = c(0.6, 0.8, 0.7)
  )

  result <- select_best_params(df)

  expect_true(nrow(result) == 1)
  expect_equal(result$mean, 0.8)
})

test_that("select_best_params errors on bad input", {

  expect_error(select_best_params("not_df"))

})

test_that("select_best_params errors if j_index missing", {

  df <- data.frame(
    .metric = c("accuracy", "precision"),
    mean = c(0.6, 0.7)
  )

  expect_error(select_best_params(df))

})
