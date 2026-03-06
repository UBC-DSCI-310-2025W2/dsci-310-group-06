# DSCI 310 Group 6 - Project Title
- Say what our project is 

# Contributors
1. Aden Chan (@21chanas3) - 93727782
2. Duncan Harrop (@harr0p) - 56144421
3. Navya Sehgal(@navyasehgal) - 76497874
4. Una Chou (@uchou92) - 55282636

# Project Summary
include summary of the project

# How to Run Data Analysis
Please follow these steps to reproduce the analysis on your local machine:
1. Clone the Repository
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
