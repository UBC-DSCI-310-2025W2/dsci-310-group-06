.PHONY: all clean

all: analysis/stroke_risk_prediction.html

analysis/stroke_risk_prediction.html: results
	quarto render analysis/stroke_risk_prediction.qmd

results: data/processed
	mkdir -p results
	bash scripts/01_download-data.bash
	Rscript scripts/02_preprocess-data.R
	Rscript scripts/03_eda-plots.R
	Rscript scripts/04_knn-model.R
	Rscript scripts/05_logreg-model.R
	Rscript scripts/06_xgboost-model.R
	Rscript scripts/07_final-model.R

clean:
	rm -rf data/processed
	rm -rf results
	rm -f analysis/stroke_risk_prediction.html 