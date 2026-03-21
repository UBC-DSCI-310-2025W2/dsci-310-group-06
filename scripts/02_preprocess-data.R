source("renv/activate.R")

library(tidyverse)
library(tidymodels)

stroke <- read_csv("data/healthcare-dataset-stroke-data.csv")

#Rename columns to all lowercase
stroke_colnames <- stroke |>
  colnames() |>
  make.names() |>
  tolower()

colnames(stroke) <- stroke_colnames

#Convert Unknown's to NA
stroke <- stroke |>
  mutate(smoking_status = na_if(smoking_status, "Unknown"))

#Convert categorical vars to factors
stroke <- stroke |>
  mutate(gender         = as_factor(gender),
         work_type      = as_factor(work_type),
         residence_type = as_factor(residence_type),
         smoking_status = as_factor(smoking_status),
         hypertension   = as_factor(hypertension),
         ever_married   = as_factor(ever_married),
         heart_disease  = as_factor(heart_disease),
         stroke         = as_factor(stroke))

#Rename factor levels to nicer names
stroke$hypertension <- recode_factor(stroke$hypertension,
                                     "0" = "No",
                                     "1" = "Yes")

stroke$heart_disease <- recode_factor(stroke$heart_disease,
                                      "0" = "No",
                                      "1" = "Yes")

stroke$stroke <- recode_factor(stroke$stroke,
                               "0" = "No",
                               "1" = "Yes")

stroke$work_type <- recode_factor(stroke$work_type,
                                  "Govt_job" = "Government",
                                  "Never_worked" = "Never Worked")

stroke$smoking_status <- recode_factor(stroke$smoking_status,
                                       "formerly smoked" = "Formerly",
                                       "never smoked" = "Never",
                                       "smokes" = "Smokes")

#For some reason bmi is of type char probably because of N/A, 
# converting to double here
stroke <- stroke |> mutate(bmi = as.numeric(as.character(bmi)))

#Dropping NA
stroke <- stroke |> drop_na()

#Removing the 1 other observation
stroke <- stroke |>
  filter(gender != "Other")

#Creating test/train split here
stroke_split <- initial_validation_split(stroke,
                                         prop = c(0.8, 0.1),
                                         strata = stroke)

stroke_training <- training(stroke_split)
stroke_validation <- validation(stroke_split)
stroke_testing <- testing(stroke_split)

# Create the directory if it doesn't exist
if (!dir.exists("data/processed")) {
  dir.create("data/processed", recursive = TRUE)
}

# Save data to seperate files
write_csv(stroke_training, "data/processed/stroke_training.csv")
write_csv(stroke_validation, "data/processed/stroke_validation.csv")
write_csv(stroke_testing, "data/processed/stroke_testing.csv")