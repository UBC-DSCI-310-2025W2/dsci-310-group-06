library(testthat)
library(here)

source(here::here("scripts", "functions", "select_best_params.R"))

test_that("select_best_params works correctly", {
  df <- data.frame(
    .metric = c("j_index", "j_index", "accuracy"),
    mean = c(0.6, 0.8, 0.9)
  )

  result <- select_best_params(df)

  expect_equal(nrow(result), 1)
  expect_equal(result$mean, 0.8)
})

test_that("select_best_params errors on bad input", {
  expect_error(select_best_params("not_df"))
  expect_error(select_best_params(data.frame(no_metric = 1)))
  expect_error(select_best_params(data.frame(.metric = "accuracy", mean = 0.5)))
})
