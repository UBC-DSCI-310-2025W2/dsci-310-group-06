<<<<<<< HEAD
# DSCI 310 Group 6 - Stroke Risk Predictions
=======
# DSCI 310 Group 6 - Project Title
- Say what our project is 
>>>>>>> 73763dc36b09a3784c7afb3caae5fc821c5d7560

# Contributors
1. Aden Chan (@21chanas3) - 93727782
2. Duncan Harrop (@harr0p) - 56144421
3. Navya Sehgal(@navyasehgal) - 76497874
4. Una Chou (@uchou92) - 55282636

# Project Summary
<<<<<<< HEAD
The research project aimed to accurately predict the occurrence of stroke in patients based on a set of clinical features. The researchers utilized the Stroke Prediction Dataset, which included information on 12 variables, such as age, gender, hypertension, heart disease, average glucose levels, BMI, smoking status, and more. By analyzing this dataset, the researchers identified patterns between these clinical features and the occurrence of stroke.
=======
include summary of the project
>>>>>>> 73763dc36b09a3784c7afb3caae5fc821c5d7560

# How to Run Data Analysis
Please follow these steps to reproduce the analysis on your local machine:
1. Clone the Repository
<<<<<<< HEAD
2. Run and execute analysis.Rmd


# Dependencies
Make sure you have the Rstudio (4.4.2) installed. The following libraries are required:
- tidyverse
- tidymodels
- repr
- gridExtra
- GGally
- broom
- ranger


# Licensing
This project is offered under the Attribution 4.0 International (CC BY 4.0) License. The software provided in this project is offered under the MIT open source license. See [License](./LICENSE.md) for more information.

=======
2. Prepare the Data
3. Execute the Code (Pipeline? tbd)
4. View Results

# Dependencies
Make sure you have the Rstudio installed. The following libraries are required:
- Pandas? (TBD)
- xxx
- xxx

# Licensing
This project is licensed under the following terms (see [License](./LICENSE.md) for full text)



## Containerization (idk if we need this anymore)

This project uses a Dockerfile and a GitHub Actions workflow to build and publish a Docker image to Docker Hub.  
The workflow triggers on changes to the Dockerfile or the workflow file, and it can also be triggered manually using `workflow_dispatch`.

The workflow logs in to Docker Hub using encrypted GitHub Actions secrets (`DOCKER_USERNAME` and `DOCKER_PASSWORD`), builds the image, and pushes it to our team’s Docker repository.
>>>>>>> 73763dc36b09a3784c7afb3caae5fc821c5d7560
