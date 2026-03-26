#' Set a consistent ggplot2 theme for all plots
#'
#' @description
#' Applies the project-specific ggplot2 theme used across all plots.
#'
#' @return Invisibly returns NULL. Sets global ggplot theme.
#'
#' @examples
#' \dontrun{
#' set_plot_theme()
#' }
set_plot_theme <- function() {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("ggplot2 must be installed to set the plot theme.")
  }

  plot_theme <- ggplot2::theme_bw(base_size = 11) +
    ggplot2::theme(
      plot.title    = ggplot2::element_text(hjust = 0.5, size = 12),
      axis.text.x   = ggplot2::element_text(size = 9),
      axis.text.y   = ggplot2::element_text(size = 9),
      axis.title.x  = ggplot2::element_text(size = 10),
      axis.title.y  = ggplot2::element_text(size = 10),
      legend.title  = ggplot2::element_text(size = 10),
      legend.text   = ggplot2::element_text(size = 9),
      strip.text    = ggplot2::element_text(size = 9)
    )

  ggplot2::theme_set(plot_theme)

  invisible(NULL)
}