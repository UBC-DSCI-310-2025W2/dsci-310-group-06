#' Plot a confusion matrix from a saved CSV
#'
#' @description
#' Reads a tidied confusion matrix CSV and generates a confusion matrix
#' using ggplot2.
#'
#' @param confusion_save_path Character. Path to the tidied confusion matrix CSV.
#' @param title Character. The title to display on the plot.
#'
#' @return A ggplot object.
#'
#' @export
plot_confusion_matrix <- function(confusion_save_path, title) {
  # 1. Load the data
  cm_data <- readr::read_csv(confusion_save_path, show_col_types = FALSE)
  
  # 2. Assign Matrix Labels (TP, FP, FN, TN)
  # Assuming 1 is 'Stroke' (Positive) and 0 is 'No Stroke' (Negative)
  cm_labeled <- cm_data |>
    dplyr::mutate(label_type = dplyr::case_when(
      Prediction == "1" & Truth == "1" ~ "TP",
      Prediction == "1" & Truth == "0" ~ "FP",
      Prediction == "0" & Truth == "1" ~ "FN",
      Prediction == "0" & Truth == "0" ~ "TN"
    )) |>
    # Combine the label and the count (e.g., "TP: 45")
    dplyr::mutate(display_text = paste0(label_type, "\n", n))
  
  # 3. Build the plot
  plot <- ggplot2::ggplot(cm_labeled, ggplot2::aes(x = Prediction, y = Truth)) +
    ggplot2::geom_tile(fill = "white", color = "black", linewidth = 1) +
    # Use the new display_text column for the labels
    ggplot2::geom_text(ggplot2::aes(label = display_text), 
                       size = 6, fontface = "bold") +
    ggplot2::labs(
      title = title,
      x = "Predicted Class",
      y = "Actual Class"
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      panel.grid = ggplot2::element_blank(),
      aspect.ratio = 1,
      plot.title = ggplot2::element_text(hjust = 0.5, face = "bold", size = 14)
    ) +
    ggplot2::scale_x_discrete(expand = c(0,0)) +
    ggplot2::scale_y_discrete(expand = c(0,0))
  
  return(plot)
}