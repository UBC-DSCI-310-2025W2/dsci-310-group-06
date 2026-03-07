# DSCI 310 Group 6 - Stroke Risk Predictions

# Contributors
1. Aden Chan (@21chanas3) - 93727782
2. Duncan Harrop (@harr0p) - 56144421
3. Navya Sehgal(@navyasehgal) - 76497874
4. Una Chou (@uchou92) - 55282636

# Project Summary
The research project aimed to accurately predict the occurrence of stroke in patients based on a set of clinical features. The researchers utilized the Stroke Prediction Dataset, which included information on 12 variables, such as age, gender, hypertension, heart disease, average glucose levels, BMI, smoking status, and more. By analyzing this dataset, the researchers identified patterns between these clinical features and the occurrence of stroke.

# How to Run Data Analysis
Please follow these steps to reproduce the analysis on your local machine:
### 1. Run Docker Image
To build the image, run:
`docker build . -t <docker_user>/<image_name>`
To run the image, run:
`docker run -p 8787:8787 -it <docker_user>/<image_name>`
The webapp will be hosted at localhost:8787. The username is rstudio and the password will be printed to the console. If you wish to specify a specific password, use:
`docker run -p 8787:8787 -e <PASSWORD> -it <docker_user>/<image_name>`

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


# Licensing
This project is offered under the Attribution 4.0 International (CC BY 4.0) License. The software provided in this project is offered under the MIT open source license. See [License](./LICENSE.md) for more information.




