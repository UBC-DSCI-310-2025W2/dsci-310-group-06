source("renv/activate.R")

library(tidyverse)
library(tidymodels)

library(docopt)

doc <- "
Usage: 02_preprocess-data.R --input=<path> --out_training=<path> --out_validation=<path> --out_testing=<path>

Options:
  --input=<path>           Path to raw stroke CSV
  --out_training=<path>    Output path for training split CSV
  --out_validation=<path>  Output path for validation split CSV
  --out_testing=<path>     Output path for testing split CSV
"

opts           <- docopt(doc)
input_path     <- opts$input
out_training   <- opts$out_training
out_validation <- opts$out_validation
out_testing    <- opts$out_testing

stroke <- read_csv(input_path)

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

# Create output directory if it doesn't exist
for (out_path in c(out_training, out_validation, out_testing)) {
  out_dir <- dirname(out_path)
  if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
}

# Save data to separate files
write_csv(stroke_training,   out_training)
write_csv(stroke_validation, out_validation)
write_csv(stroke_testing,    out_testing)