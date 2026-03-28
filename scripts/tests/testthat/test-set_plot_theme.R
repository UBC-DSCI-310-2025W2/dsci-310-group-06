library(testthat)
library(ggplot2)

source(here::here("scripts", "functions", "set_plot_theme.R"))

test_that("set_plot_theme errors if ggplot2 is unavailable", {
  fn_env <- environment(set_plot_theme)
  old_requireNamespace <- get("requireNamespace", envir = fn_env)

  assign(
    "requireNamespace",
    function(package, quietly = TRUE) FALSE,
    envir = fn_env
  )

  on.exit(
    assign("requireNamespace", old_requireNamespace, envir = fn_env),
    add = TRUE
  )

  expect_error(
    set_plot_theme(),
    "ggplot2 must be installed to set the plot theme."
  )
})

test_that("set_plot_theme runs without error", {
  expect_no_error(set_plot_theme())
})

test_that("set_plot_theme returns NULL invisibly", {
  expect_null(set_plot_theme())
})

test_that("set_plot_theme sets expected theme elements", {
  set_plot_theme()
  current_theme <- ggplot2::theme_get()

  expect_equal(current_theme$plot.title$hjust, 0.5)
  expect_equal(current_theme$plot.title$size, 12)
  expect_equal(current_theme$axis.text.x$size, 9)
  expect_equal(current_theme$axis.text.y$size, 9)
  expect_equal(current_theme$axis.title.x$size, 10)
  expect_equal(current_theme$axis.title.y$size, 10)
  expect_equal(current_theme$legend.title$size, 10)
  expect_equal(current_theme$legend.text$size, 9)
  expect_equal(current_theme$strip.text$size, 9)

  expect_false(is.null(current_theme$plot.margin))
  expect_true(inherits(current_theme$panel.grid.minor, "element_blank"))
})