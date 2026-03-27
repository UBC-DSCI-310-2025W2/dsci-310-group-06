source("renv/activate.R")
source("scripts/functions/get_summary_stats.R")

library(tidyverse)
library(tidymodels)
library(gridExtra)
library(GGally)
library(scales)
library(grid)

# Create directories
if (!dir.exists("results/figures")) {
  dir.create("results/figures", recursive = TRUE)
}

if (!dir.exists("results/tables")) {
  dir.create("results/tables", recursive = TRUE)
}

# Load training data
stroke_training <- read_csv("data/processed/stroke_training.csv")

# Remove id column from training set (not a predictor)
stroke_training <- stroke_training |> select(-id)

# Plot themeing

plot_theme <- theme_bw(base_size = 11) +
  theme(
    plot.title    = element_text(hjust = 0.5, size = 12),
    axis.text.x   = element_text(size = 9),
    axis.text.y   = element_text(size = 9),
    axis.title.x  = element_text(size = 10),
    axis.title.y  = element_text(size = 10),
    legend.title  = element_text(size = 10),
    legend.text   = element_text(size = 9),
    strip.text    = element_text(size = 9)
  )


# Table 01: Summary stats using function

stroke_married_stats <- get_summary_stats(stroke_training, "ever_married")

stroke_work_stats <- get_summary_stats(stroke_training, "work_type")

stroke_gender_stats <- get_summary_stats(stroke_training, "gender")

stroke_residence_type_stats <- get_summary_stats(stroke_training, "residence_type")

stroke_smoking_status_stats <- get_summary_stats(stroke_training, "smoking_status")

stroke_hypertension_stats <- get_summary_stats(
  stroke_training, "hypertension",
  coerce.char = TRUE,
  new.key = "hypertension")

stroke_heart_disease_stats <- get_summary_stats(
  stroke_training, "heart_disease",
  coerce.char = TRUE,
  new.key = "heart_disease")

stroke_stroke_stats <- get_summary_stats(
  stroke_training, "stroke",
  coerce.char = TRUE,
  new.key = "stroke")

# Numeric vars
stroke_numeric_cols_summary <- stroke_training |>
  select(avg_glucose_level, bmi, age) |>
  map_dfc(mean, na.rm = TRUE)

# Combine into a summary table
stroke_summary_stats <- stroke_numeric_cols_summary |>
  pivot_longer(age:avg_glucose_level,
               names_to = "column_name",
               values_to = "value") |>
  mutate(key = "mean") |>
  bind_rows(
    stroke_gender_stats,
    stroke_residence_type_stats,
    stroke_smoking_status_stats,
    stroke_stroke_stats,
    stroke_hypertension_stats,
    stroke_heart_disease_stats,
    stroke_work_stats,
    stroke_married_stats
  )
stroke_summary_stats <- stroke_summary_stats[, c(1, 3, 2)]

write_csv(stroke_summary_stats, "results/tables/01_summary-stats.csv")

# Figure 01: ggpairs plot

stroke_pairs <- stroke_training |>
  select(stroke,
         age,
         avg_glucose_level,
         bmi,
         hypertension,
         heart_disease)

plot_pairs <- ggpairs(
  stroke_pairs,
  columns = 2:6,
  mapping = aes(color = stroke, alpha = 0.5),
  upper   = list(continuous = wrap("points", size = 0.4)),
  lower   = list(continuous = wrap("smooth", se = FALSE, alpha = 0.3)),
  diag    = list(continuous = wrap("densityDiag", alpha = 0.5))
) +
  labs(
    title = "Pairwise relationships among selected stroke predictors",
    color = "Stroke"
  ) +
  theme_bw(base_size = 10) +
  theme(
    plot.title      = element_text(hjust = 0.5, size = 12),
    legend.position = "bottom",
    axis.text.x     = element_text(size = 8),
    axis.text.y     = element_text(size = 8),
    strip.text      = element_text(size = 9)
  )

suppressMessages(suppressWarnings(
  ggsave("results/figures/01_ggpairs-plot.png",
         plot = plot_pairs, width = 12, height = 10)
))

# Figure 02: Stroke by gender

stroke_gender <- stroke_training |>
  count(gender, stroke) |>
  group_by(gender) |>
  mutate(percentage = n / sum(n)) |>
  ggplot(aes(x = gender, y = percentage, fill = stroke)) +
  geom_col(width = 0.75) +
  scale_y_continuous(labels = percent_format()) +
  labs(
    x     = "Gender",
    y     = "Percentage",
    fill  = "Stroke",
    title = "Percentage of stroke cases by gender"
  ) +
  plot_theme

ggsave("results/figures/02_stroke-by-gender.png",
       plot = stroke_gender, width = 8, height = 5)

# Figure 03: Stroke by age

stroke_age <- stroke_training |>
  ggplot(aes(x = age, fill = stroke)) +
  geom_histogram(position = "fill", binwidth = 5, color = "white") +
  scale_y_continuous(labels = percent_format()) +
  labs(
    x     = "Age",
    y     = "Proportion",
    fill  = "Stroke",
    title = "Proportion of stroke cases by age group"
  ) +
  plot_theme

ggsave("results/figures/03_stroke-by-age.png",
       plot = stroke_age, width = 10, height = 6)

# Figure 04: Stroke by hypertension

stroke_hypertension <- stroke_training |>
  count(hypertension, stroke) |>
  group_by(hypertension) |>
  mutate(percentage = n / sum(n)) |>
  ggplot(aes(x = hypertension, y = percentage, fill = stroke)) +
  geom_col(width = 0.75) +
  scale_y_continuous(labels = percent_format()) +
  labs(
    x     = "Hypertension",
    y     = "Percentage",
    fill  = "Stroke",
    title = "Percentage of stroke cases by hypertension"
  ) +
  plot_theme

ggsave("results/figures/04_stroke-by-hypertension.png",
       plot = stroke_hypertension, width = 8, height = 5)

# Figure 05: Stroke by heart disease

stroke_heart_disease <- stroke_training |>
  count(heart_disease, stroke) |>
  group_by(heart_disease) |>
  mutate(percentage = n / sum(n)) |>
  ggplot(aes(x = heart_disease, y = percentage, fill = stroke)) +
  geom_col(width = 0.75) +
  scale_y_continuous(labels = percent_format()) +
  labs(
    x     = "Heart disease",
    y     = "Percentage",
    fill  = "Stroke",
    title = "Percentage of stroke cases by heart disease"
  ) +
  plot_theme

ggsave("results/figures/05_stroke-by-heart-disease.png",
       plot = stroke_heart_disease, width = 8, height = 5)

# Figure 06: Stroke by residence type

stroke_residence <- stroke_training |>
  count(residence_type, stroke) |>
  group_by(residence_type) |>
  mutate(percentage = n / sum(n)) |>
  ggplot(aes(x = residence_type, y = percentage, fill = stroke)) +
  geom_col(width = 0.75) +
  scale_y_continuous(labels = percent_format()) +
  labs(
    x     = "Type of residence",
    y     = "Percentage",
    fill  = "Stroke",
    title = "Percentage of stroke cases by type of residence"
  ) +
  plot_theme

ggsave("results/figures/06_stroke-by-residence.png",
       plot = stroke_residence, width = 8, height = 5)

# Figure 07: Average glucose level by stroke status

stroke_avg_glucose_level <- stroke_training |>
  ggplot(aes(x = stroke, y = avg_glucose_level, fill = stroke)) +
  geom_boxplot(alpha = 0.8, width = 0.6) +
  labs(
    x     = "Stroke",
    y     = "Average glucose level",
    fill  = "Stroke",
    title = "Average glucose level by stroke status"
  ) +
  plot_theme +
  theme(legend.position = "none")

ggsave("results/figures/07_glucose-by-stroke.png",
       plot = stroke_avg_glucose_level, width = 8, height = 6)

# Figure 08: BMI by stroke status

stroke_bmi <- stroke_training |>
  ggplot(aes(x = stroke, y = bmi, fill = stroke)) +
  geom_boxplot(alpha = 0.8, width = 0.6, na.rm = TRUE) +
  labs(
    x     = "Stroke",
    y     = "BMI",
    fill  = "Stroke",
    title = "BMI by stroke status"
  ) +
  plot_theme +
  theme(legend.position = "none")

ggsave("results/figures/08_bmi-by-stroke.png",
       plot = stroke_bmi, width = 8, height = 6)

# Figure 09: Stroke by smoking status

stroke_smoking_status <- stroke_training |>
  count(smoking_status, stroke) |>
  group_by(smoking_status) |>
  mutate(percentage = n / sum(n)) |>
  ggplot(aes(x = smoking_status, y = percentage, fill = stroke)) +
  geom_col() +
  scale_y_continuous(labels = percent_format()) +
  labs(
    x     = "Smoking status",
    y     = "Percentage",
    fill  = "Stroke",
    title = "Percentage of stroke cases by smoking status"
  ) +
  plot_theme +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

ggsave("results/figures/09_stroke-by-smoking.png",
       plot = stroke_smoking_status, width = 9, height = 5)

# Figure 10: Stroke by work type

stroke_worktype_plot <- stroke_training |>
  count(work_type, stroke) |>
  group_by(work_type) |>
  mutate(percentage = n / sum(n)) |>
  ggplot(aes(x = work_type, y = percentage, fill = stroke)) +
  geom_col() +
  scale_y_continuous(labels = percent_format()) +
  labs(
    x     = "Type of work",
    y     = "Percentage",
    fill  = "Stroke",
    title = "Percentage of stroke cases by work type"
  ) +
  plot_theme +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

ggsave("results/figures/10_stroke-by-work-type.png",
       plot = stroke_worktype_plot, width = 10, height = 5)

# Figure 11: Stroke by age group and gender

stroke_age_gender <- stroke_training |>
  ggplot(aes(x = age, fill = stroke)) +
  geom_histogram(position = "fill", binwidth = 5, color = "white") +
  facet_wrap(~ gender) +
  scale_y_continuous(labels = percent_format()) +
  labs(
    x     = "Age",
    y     = "Proportion",
    fill  = "Stroke",
    title = "Proportion of stroke cases by age group and gender"
  ) +
  plot_theme

ggsave("results/figures/11_stroke-by-age-gender.png",
       plot = stroke_age_gender, width = 14, height = 5)

# Figure 12: Stroke by age group and smoking status

stroke_age_smoking <- stroke_training |>
  ggplot(aes(x = age, fill = stroke)) +
  geom_histogram(position = "fill", binwidth = 5, color = "white") +
  facet_wrap(~ smoking_status) +
  scale_y_continuous(labels = percent_format()) +
  labs(
    x     = "Age",
    y     = "Proportion",
    fill  = "Stroke",
    title = "Proportion of stroke cases by age group and smoking status"
  ) +
  plot_theme

ggsave("results/figures/12_stroke-by-age-smoking.png",
       plot = stroke_age_smoking, width = 12, height = 6)

# Figure 13: Stroke by hypertension and heart disease

heartdisease_hypertension <- stroke_training |>
  count(hypertension, heart_disease, stroke) |>
  group_by(hypertension, heart_disease) |>
  mutate(percentage = n / sum(n)) |>
  ungroup()

heartdisease_hypertension_plot <- ggplot(
  heartdisease_hypertension,
  aes(x = hypertension, y = percentage, fill = stroke)
) +
  geom_col(position = "stack") +
  facet_wrap(~ heart_disease) +
  scale_y_continuous(labels = percent_format()) +
  labs(
    x     = "Hypertension",
    y     = "Percentage",
    fill  = "Stroke",
    title = "Percentage of stroke cases by hypertension and heart disease"
  ) +
  plot_theme

ggsave("results/figures/13_stroke-by-hypertension-heart-disease.png",
       plot = heartdisease_hypertension_plot, width = 8, height = 6)

# Figure 14: Stroke by gender and heart disease

heartdisease_gender <- stroke_training |>
  count(gender, heart_disease, stroke) |>
  group_by(gender, heart_disease) |>
  mutate(percentage = n / sum(n))

stroke_gender_plot <- heartdisease_gender |>
  ggplot(aes(x = heart_disease, y = percentage, fill = stroke)) +
  geom_col() +
  facet_wrap(~ gender) +
  scale_y_continuous(labels = percent_format()) +
  labs(
    x     = "Heart disease",
    y     = "Percentage",
    fill  = "Stroke",
    title = "Percentage of stroke cases by gender and heart disease"
  ) +
  plot_theme

ggsave("results/figures/14_stroke-by-gender-heart-disease.png",
       plot = stroke_gender_plot, width = 10, height = 5)

# Figure 15: Stroke by age and BMI

age_bmi <- stroke_training |>
  ggplot(aes(x = age, y = bmi, colour = stroke)) +
  geom_point(alpha = 0.5) +
  labs(
    x     = "Age",
    y     = "BMI",
    color = "Stroke",
    title = "Stroke cases by age and BMI"
  ) +
  plot_theme +
  scale_color_manual(
    values = alpha(c("No" = "#F8766D", "Yes" = "#00BFC4"), c(0.2, 1.0))
  )

ggsave("results/figures/15_stroke-by-age-bmi.png",
       plot = age_bmi, width = 8, height = 6)

# Figure 16: Stroke by average glucose level and BMI

glucose_bmi <- stroke_training |>
  ggplot(aes(x = bmi, y = avg_glucose_level, colour = stroke)) +
  geom_point(alpha = 0.5) +
  labs(
    x     = "BMI",
    y     = "Average glucose level",
    color = "Stroke",
    title = "Stroke cases by average glucose level and BMI"
  ) +
  plot_theme +
  scale_color_manual(
    values = alpha(c("No" = "#F8766D", "Yes" = "#00BFC4"), c(0.2, 1.0))
  )

ggsave("results/figures/16_stroke-by-glucose-bmi.png",
       plot = glucose_bmi, width = 8, height = 6)

# Figure 17: Stroke by glucose level with hypertension and heart disease

glucose_hypertension <- stroke_training |>
  ggplot(aes(x = avg_glucose_level, y = hypertension, colour = stroke)) +
  geom_jitter(height = 0.15, width = 0, alpha = 0.5) +
  labs(
    title = "A. Hypertension",
    x     = "Average glucose level",
    y     = "Hypertension",
    color = "Stroke"
  ) +
  plot_theme +
  theme(legend.position = "none") +
  scale_color_manual(
    values = alpha(c("No" = "#F8766D", "Yes" = "#00BFC4"), c(0.2, 1.0))
  )

glucose_heartdisease <- stroke_training |>
  ggplot(aes(x = avg_glucose_level, y = heart_disease, colour = stroke)) +
  geom_jitter(height = 0.15, width = 0, alpha = 0.5) +
  labs(
    title = "B. Heart disease",
    x     = "Average glucose level",
    y     = "Heart disease",
    color = "Stroke"
  ) +
  plot_theme +
  scale_color_manual(
    values = alpha(c("No" = "#F8766D", "Yes" = "#00BFC4"), c(0.2, 1.0))
  )

png("results/figures/17_stroke-by-glucose-hypertension-heart-disease.png",
    width = 15, height = 6, units = "in", res = 150)
grid.arrange(
  glucose_hypertension,
  glucose_heartdisease,
  ncol = 2,
  top  = textGrob(
    "Stroke cases by glucose level with hypertension and heart disease",
    gp = gpar(fontsize = 12)
  )
)
dev.off()

# Figure 18: Stroke by residence type with heart disease and hypertension

residence_heartdisease <- stroke_training |>
  ggplot(aes(x = residence_type, y = heart_disease, colour = stroke)) +
  geom_jitter(width = 0.15, height = 0.15, alpha = 0.5) +
  labs(
    title = "A. Heart disease",
    x     = "Type of residence",
    y     = "Heart disease",
    color = "Stroke"
  ) +
  plot_theme +
  theme(legend.position = "none") +
  scale_color_manual(
    values = alpha(c("No" = "#F8766D", "Yes" = "#00BFC4"), c(0.2, 1.0))
  )

residence_hypertension <- stroke_training |>
  ggplot(aes(x = residence_type, y = hypertension, colour = stroke)) +
  geom_jitter(width = 0.15, height = 0.15, alpha = 0.5) +
  labs(
    title = "B. Hypertension",
    x     = "Type of residence",
    y     = "Hypertension",
    color = "Stroke"
  ) +
  plot_theme +
  scale_color_manual(
    values = alpha(c("No" = "#F8766D", "Yes" = "#00BFC4"), c(0.2, 1.0))
  )

png("results/figures/18_stroke-by-residence-heart-disease-hypertension.png",
    width = 15, height = 6, units = "in", res = 150)
grid.arrange(
  residence_heartdisease,
  residence_hypertension,
  ncol = 2,
  top  = textGrob(
    "Stroke cases by residence type with heart disease and hypertension",
    gp = gpar(fontsize = 12)
  )
)
dev.off()

heartdisease_residence <- stroke_training %>%
  count(residence_type, heart_disease, stroke) %>%
  group_by(residence_type, heart_disease) %>%
  mutate(percentage = n / sum(n)) %>%
  ungroup() %>%
  ggplot(aes(x = residence_type, y = percentage, fill = stroke)) +
  geom_col() +
  facet_wrap(~ heart_disease) +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(
    title = "A. Heart disease",
    x = "Type of residence",
    y = "Percentage",
    fill = "Stroke"
  ) +
  plot_theme +
  theme(legend.position = "none")

hypertension_residence <- stroke_training %>%
  count(residence_type, hypertension, stroke) %>%
  group_by(residence_type, hypertension) %>%
  mutate(percentage = n / sum(n)) %>%
  ungroup() %>%
  ggplot(aes(x = residence_type, y = percentage, fill = stroke)) +
  geom_col() +
  facet_wrap(~ hypertension) +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(
    title = "B. Hypertension",
    x = "Type of residence",
    y = "Percentage",
    fill = "Stroke"
  ) +
  plot_theme

png("results/figures/19_stroke-percentages-by-residence-heart-disease-hypertension.png",
    width = 15, height = 6, units = "in", res = 150)
grid.arrange(
  heartdisease_residence,
  hypertension_residence,
  ncol = 2,
  top = textGrob(
    "Stroke percentages by residence, heart disease, and hypertension",
    gp = gpar(fontsize = 12)
  )
)
dev.off()
