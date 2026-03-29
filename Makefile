.PHONY: clean all

all: results/figures/01_ggpairs-plot.png \
	 results/figures/02_stroke-by-gender.png \
	 results/figures/03_stroke-by-age.png \
	 results/figures/04_stroke-by-hypertension.png \
	 results/figures/05_stroke-by-heart-disease.png \
	 results/figures/06_stroke-by-residence.png \
	 results/figures/07_glucose-by-stroke.png \
	 results/figures/08_bmi-by-stroke.png \
	 results/figures/09_stroke-by-smoking.png \
	 results/figures/10_stroke-by-work-type.png \
	 results/figures/11_stroke-by-age-gender.png \
	 results/figures/12_stroke-by-age-smoking.png \
	 results/figures/13_stroke-by-hypertension-heart-disease.png \
	 results/figures/14_stroke-by-gender-heart-disease.png \
	 results/figures/15_stroke-by-age-bmi.png \
	 results/figures/16_stroke-by-glucose-bmi.png \
	 results/figures/17_stroke-by-glucose-hypertension-heart-disease.png \
	 results/figures/18_stroke-by-residence-heart-disease-hypertension.png \
	 results/figures/19_stroke-percentages-by-residence-heart-disease-hypertension.png \
	 results/figures/20_coarse-knn-k-sweep.png \
	 results/figures/21_xgboost-feature-importance.png \
	 results/figures/22_validation-metrics-comparison.png \
	 results/figures/23_validation-confusion-matrices.png \
	 results/figures/24_final-model-test-confusion.png \
	 results/tables/01_summary-stats.csv \
	 results/tables/02_coarse-knn-cv-results.csv \
	 results/tables/03_fine-knn-cv-results.csv \
	 results/tables/04_knn-validation-metrics.csv \
	 results/tables/05_knn-confusion-matrix.csv \
	 results/tables/06_logreg-backward-selection-terms.csv \
	 results/tables/07_logreg-best-params.csv \
	 results/tables/08_logreg-validation-metrics.csv \
	 results/tables/09_logreg-confusion-matrix.csv \
	 results/tables/10_xgboost-best-params.csv \
	 results/tables/11_xgboost-validation-metrics.csv \
	 results/tables/12_xgboost-confusion-matrix.csv \
	 results/tables/13_all-validation-metrics.csv \
	 results/tables/14_final-model-test-metrics.csv \
	 results/tables/15_final-model-test-confusion-matrix.csv \
	 results/models/knn_fit.rds \
	 results/models/logr_fit.rds \
	 results/models/xgb_fit.rds \
	 analysis/stroke_risk_prediction.pdf

# 01 — Raw data
data/healthcare-dataset-stroke-data.csv:
	bash scripts/01_download-data.bash

# 02 — Preprocessing
data/processed/stroke_training.csv \
data/processed/stroke_validation.csv \
data/processed/stroke_testing.csv &: data/healthcare-dataset-stroke-data.csv
	Rscript scripts/02_preprocess-data.R \
		--input=data/healthcare-dataset-stroke-data.csv \
		--out_training=data/processed/stroke_training.csv \
		--out_validation=data/processed/stroke_validation.csv \
		--out_testing=data/processed/stroke_testing.csv

# 03 — EDA
results/tables/01_summary-stats.csv \
results/figures/01_ggpairs-plot.png \
results/figures/02_stroke-by-gender.png \
results/figures/03_stroke-by-age.png \
results/figures/04_stroke-by-hypertension.png \
results/figures/05_stroke-by-heart-disease.png \
results/figures/06_stroke-by-residence.png \
results/figures/07_glucose-by-stroke.png \
results/figures/08_bmi-by-stroke.png \
results/figures/09_stroke-by-smoking.png \
results/figures/10_stroke-by-work-type.png \
results/figures/11_stroke-by-age-gender.png \
results/figures/12_stroke-by-age-smoking.png \
results/figures/13_stroke-by-hypertension-heart-disease.png \
results/figures/14_stroke-by-gender-heart-disease.png \
results/figures/15_stroke-by-age-bmi.png \
results/figures/16_stroke-by-glucose-bmi.png \
results/figures/17_stroke-by-glucose-hypertension-heart-disease.png \
results/figures/18_stroke-by-residence-heart-disease-hypertension.png \
results/figures/19_stroke-percentages-by-residence-heart-disease-hypertension.png &: data/processed/stroke_training.csv
	Rscript scripts/03_eda-plots.R \
		--input=data/processed/stroke_training.csv \
		--out_figures_dir=results/figures \
		--out_tables_dir=results/tables

# 04 — kNN
results/figures/20_coarse-knn-k-sweep.png \
results/tables/02_coarse-knn-cv-results.csv \
results/tables/03_fine-knn-cv-results.csv \
results/tables/04_knn-validation-metrics.csv \
results/tables/05_knn-confusion-matrix.csv \
results/models/knn_fit.rds &: data/processed/stroke_training.csv \
	data/processed/stroke_validation.csv
	Rscript scripts/04_knn-model.R \
		--training=data/processed/stroke_training.csv \
		--validation=data/processed/stroke_validation.csv \
		--out_figures_dir=results/figures \
		--out_tables_dir=results/tables \
		--out_models_dir=results/models

# 05 — Log reg
results/tables/06_logreg-backward-selection-terms.csv \
results/tables/07_logreg-best-params.csv \
results/tables/08_logreg-validation-metrics.csv \
results/tables/09_logreg-confusion-matrix.csv \
results/models/logr_fit.rds &: data/processed/stroke_training.csv \
	data/processed/stroke_validation.csv
	Rscript scripts/05_logreg-model.R \
		--training=data/processed/stroke_training.csv \
		--validation=data/processed/stroke_validation.csv \
		--out_figures_dir=results/figures \
		--out_tables_dir=results/tables \
		--out_models_dir=results/models

# 06 - XGBoost
results/figures/21_xgboost-feature-importance.png \
results/tables/10_xgboost-best-params.csv \
results/tables/11_xgboost-validation-metrics.csv \
results/tables/12_xgboost-confusion-matrix.csv \
results/models/xgb_fit.rds &: data/processed/stroke_training.csv \
	data/processed/stroke_validation.csv
	Rscript scripts/06_xgboost-model.R \
		--training=data/processed/stroke_training.csv \
		--validation=data/processed/stroke_validation.csv \
		--out_figures_dir=results/figures \
		--out_tables_dir=results/tables \
		--out_models_dir=results/models

# 07 - Final comparison
results/figures/22_validation-metrics-comparison.png \
results/figures/23_validation-confusion-matrices.png \
results/figures/24_final-model-test-confusion.png \
results/tables/13_all-validation-metrics.csv \
results/tables/14_final-model-test-metrics.csv \
results/tables/15_final-model-test-confusion-matrix.csv &: \
	results/models/knn_fit.rds \
	results/models/logr_fit.rds \
	results/models/xgb_fit.rds \
	data/processed/stroke_testing.csv
	Rscript scripts/07_final-model.R \
		--testing=data/processed/stroke_testing.csv \
		--knn_metrics=results/tables/04_knn-validation-metrics.csv \
		--logreg_metrics=results/tables/08_logreg-validation-metrics.csv \
		--xgb_metrics=results/tables/11_xgboost-validation-metrics.csv \
		--knn_cm=results/tables/05_knn-confusion-matrix.csv \
		--logreg_cm=results/tables/09_logreg-confusion-matrix.csv \
		--xgb_cm=results/tables/12_xgboost-confusion-matrix.csv \
		--knn_model=results/models/knn_fit.rds \
		--logreg_model=results/models/logr_fit.rds \
		--xgb_model=results/models/xgb_fit.rds \
		--out_figures_dir=results/figures \
		--out_tables_dir=results/tables

# 08 - Quarto
analysis/stroke_risk_prediction.pdf: \
	results \
	analysis/stroke_risk_prediction.qmd
	quarto render analysis/stroke_risk_prediction.qmd --to pdf


clean:
	rm -rf data/processed
	rm -rf results
	rm -f analysis/stroke_risk_prediction.pdf
