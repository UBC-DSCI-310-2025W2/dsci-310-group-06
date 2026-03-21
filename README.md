# DSCI 310 Group 6 - Stroke Risk Predictions

# Contributors
1. Aden Chan (@21chanas3) - 93727782
2. Duncan Harrop (@harr0p) - 56144421
3. Navya Sehgal(@navyasehgal) - 76497874
4. Una Chou (@uchou92) - 55282636

# Project Summary
This project explored the ability to predict the likelihood of a patient experiencing a stroke based on clinical features such as age, average glucose levels, BMI, and pre-existing conditions like hypertension and heart disease. Through exploratory data analysis, we identified that older age (particularly over 55), higher average glucose levels, and the presence of heart disease or hypertension are strongly associated with an increased prevalence of strokes.

To formalize these predictions and address the severe class imbalance inherent in the dataset, we applied the Synthetic Minority Over-sampling Technique (SMOTE) to rebalance our data prior to training. We then developed and evaluated three distinct classification models: K-Nearest Neighbors (KNN), regularized Logistic Regression, and XGBoost. To prevent the models from defaulting to the majority "No stroke" class—and to ensure we weren't masking poor predictive performance with high overall accuracy—we evaluated the models using the J-index, which equally weights sensitivity and specificity. Logistic Regression emerged as the strongest candidate, significantly outperforming the others in minimizing false negatives, ultimately achieving a J-index of 0.5556 on the final unseen test set.

***What this means:*** Our findings demonstrate that utilizing data rebalancing techniques like SMOTE and optimizing for comprehensive metrics like the J-index can successfully combat class imbalance and reduce dangerous Type II errors (false negatives) where at-risk patients are missed. However, the model still produced a notable number of false positives and exhibited some difficulty generalizing to new data. This indicates that while clinical snapshots are useful, building a highly accurate, clinically viable predictive tool requires incorporating broader, patient-specific variables, such as genetic history, detailed lifestyle choices, and longitudinal health records.
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
- themis
- repr
- gridExtra
- glmnet
- GGally
- broom
- finetune
- xgboost
- ranger
- vip
- repr
- gridExtra
- GGally
- broom
- ranger

All R package dependencies are managed using `renv` and are listed in the [`renv.lock`](renv.lock) file. The computational environment is also containerized; see the [`Dockerfile`](Dockerfile) for the exact system requirements and setup.

# Licensing
This project is offered under the Attribution 4.0 International (CC BY 4.0) License. The software provided in this project is offered under the MIT open source license. See [License](./LICENSE.md) for more information.




