# DSCI 310 Group 6 - Stroke Risk Predictions

# Contributors
1. Aden Chan (@21chanas3) - 93727782
2. Duncan Harrop (@harr0p) - 56144421
3. Navya Sehgal(@navyasehgal) - 76497874
4. Una Chou (@uchou92) - 55282636

# Project Summary

This project explored the ability to predict the likelihood of a patient experiencing a stroke based on clinical features such as age, BMI, average glucose levels, and pre-existing conditions (hypertension and heart disease). Through exploratory data analysis, we identified that older age, higher BMI, hypertension, and heart disease are visibly associated with an increased prevalence of strokes. 

To formalize these predictions, we trained a K-Nearest Neighbors (KNN) classification model. However, our results revealed a critical limitation: despite achieving a seemingly high overall accuracy of 94.5%, the model suffered from severe class imbalance and predicted "No stroke" for every single patient in the test set. 

**What this means:** Our findings demonstrate that standard classification models trained on heavily imbalanced clinical data will default to the majority class, resulting in dangerous Type II errors (false negatives) where at-risk patients are missed. To build a clinically viable predictive tool, future iterations must utilize data rebalancing techniques (like oversampling the stroke cases) and likely need to incorporate broader, patient-specific variables such as genetic history and detailed lifestyle choices.
# How to Run Data Analysis
Please follow these steps to reproduce the analysis on your local machine:
### 1. Run Docker Image
To build the image, run:
`docker build . navyasehgal/dsci310group6:latest .`

To run the image, run:
`docker run -p 8787:8787 -it navyasehgal/dsci310group6:latest`

The webapp will be hosted at localhost:8787. The username is rstudio and the password will be printed to the console. If you wish to specify a specific password, use:
`docker run -p 8787:8787 -e PASSWORD=<YOUR_PASSWORD> -it $navyasehgal/dsci310group6:latest`

### 2. Run and execute analysis.Rmd


# Dependencies
Make sure you have the Rstudio (4.4.2) installed. The following libraries are required:
- tidyverse
- tidymodels
- repr
- gridExtra
- GGally
- broom
- ranger

All R package dependencies are managed using `renv` and are listed in the [`renv.lock`](renv.lock) file. The computational environment is also containerized; see the [`Dockerfile`](Dockerfile) for the exact system requirements and setup.

# Licensing
This project is offered under the Attribution 4.0 International (CC BY 4.0) License. The software provided in this project is offered under the MIT open source license. See [License](./LICENSE.md) for more information.




