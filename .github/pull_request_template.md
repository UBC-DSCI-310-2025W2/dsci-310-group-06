# Pull Request

## Description

This PR implements the plot_confusion_matrix function as specified in Task #30. This function completes the evaluation pipeline by taking the tidied CSV output from evaluate_model (#29) and generating a standardized, square-format confusion matrix plot using ggplot2.

Key Changes:

Created plot_confusion_matrix.R in scripts/functions/.

Implemented automated labeling for TP, FP, FN, and TN within the matrix cells to improve interpretability.

Added a test in scripts/tests/testthat/test-plot_confusion_matrix.R.

Ensured the function adheres to project standards by using explicit package::function() syntax (e.g., ggplot2::geom_tile, readr::read_csv).

## Checklist:

- [ ] My code follows the style guidelines of this project
- [ ] This pull request contains commits for the develop of no more than 1 function
- [ ] I have performed a self-review of my own code
- [ ] I have added appropriate `roxygen2` style documentation to my functions
- [ ] I have create test cases for my function using `testthat`
- [ ] I have added a reviewer to this pull request
- [ ] I have rerun the full pipeline with my changes
- [ ] New and existing unit tests pass locally with my changes
- [ ] Any dependent changes have been merged and published in downstream modules
