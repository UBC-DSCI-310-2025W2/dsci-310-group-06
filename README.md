# DSCI 310 Group 6 - Stroke Risk Predictions

# Contributors

1.  Aden Chan (@21chanas3) - 93727782
2.  Duncan Harrop (@harr0p) - 56144421
3.  Navya Sehgal (@navyasehgal) - 76497874
4.  Una Chou (@uchou92) - 55282636

# Project Summary

This project explored the ability to predict the likelihood of a patient experiencing a stroke based on clinical features such as age, average glucose levels, BMI, and pre-existing conditions like hypertension and heart disease. Through exploratory data analysis, we identified that older age (particularly over 55), higher average glucose levels, and the presence of heart disease or hypertension are strongly associated with an increased prevalence of strokes.

To formalize these predictions and address the severe class imbalance inherent in the dataset, we applied the Synthetic Minority Over-sampling Technique (SMOTE) to rebalance our data prior to training. We then developed and evaluated three distinct classification models: K-Nearest Neighbors (KNN), regularized Logistic Regression, and XGBoost. To prevent the models from defaulting to the majority "No stroke" class—and to ensure we weren't masking poor predictive performance with high overall accuracy—we evaluated the models using the J-index, which equally weights sensitivity and specificity. Logistic Regression emerged as the strongest candidate, significantly outperforming the others in minimizing false negatives, ultimately achieving a J-index of 0.5556 on the final unseen test set.

***What this means:*** Our findings demonstrate that utilizing data rebalancing techniques like SMOTE and optimizing for comprehensive metrics like the J-index can successfully combat class imbalance and reduce dangerous Type II errors (false negatives) where at-risk patients are missed. However, the model still produced a notable number of false positives and exhibited some difficulty generalizing to new data. This indicates that while clinical snapshots are useful, building a highly accurate, clinically viable predictive tool requires incorporating broader, patient-specific variables, such as genetic history, detailed lifestyle choices, and longitudinal health records.

# How to Run Data Analysis

Please follow these steps to reproduce the analysis:

### 1. Run Docker Image

To build the image, run the following command in your terminal:
`docker build -t navyasehgal/dsci310group6:latest .`

To run the container and access the environment, use:
`docker run -p 8787:8787 -it navyasehgal/dsci310group6:latest`

The RStudio instance will be hosted at `localhost:8787`. The default username is `rstudio`. By default, a random password will be printed to the terminal console during startup. If you prefer to specify your own password, run the container using the `-e PASSWORD` flag:
`docker run -p 8787:8787 -e PASSWORD=<YOUR_PASSWORD> -it navyasehgal/dsci310group6:latest`

### 2. Execute Analysis via Makefile

Once inside the project environment (either via Docker or your local terminal), use the `Makefile` to automate the data processing, modeling, and reporting:

-   **To run the entire pipeline and generate the report:** `bash     make all`
-   **To clean all generated data and results:** `bash     make clean`

The final report is generated as a Quarto document located at:
`analysis/stroke_risk_prediction.qmd`

# Dependencies
The project environment is managed via `renv`. The analysis requires **R (version 4.3.2)** and **Quarto**. The full list of R package dependencies and their exact versions are recorded in [`renv.lock`](renv.lock). Key packages include:

| Package | Version | Purpose |
| :--- | :--- | :--- |
| `tidyverse` | 2.0.0 | Data manipulation and visualization |
| `tidymodels` | 1.4.1 | Modeling framework |
| `xgboost` | 3.2.1.1 | Gradient boosting model |
| `themis` | 1.0.3 | SMOTE data rebalancing |
| `GGally` | 2.4.0 | Correlation and EDA plots |
| `glmnet` | 4.1-10 | Regularized regression |
| `here` | 1.0.2 | Robust file path management |
| `knitr` | 1.51 | Dynamic document generation |
| `rmarkdown` | 2.30 | Rendering support |
| `gridExtra` | 2.3 | Arranging multiple plots |
| `vip` | 0.4.5 | Variable importance plots |
| `kknn` | 1.4.1 | KNN model backend |
| `finetune` | 1.2.1 | Hyperparameter tuning (race methods) |
| `kableExtra` | 1.4.0 | Table formatting in report |
| `docopt` | 0.7.2 | CLI argument parsing in scripts |

# Licensing
This project is offered under the Attribution 4.0 International (CC BY 4.0) License. The software provided in this project is offered under the MIT open source license. See [License](./LICENSE.md) for more information.
