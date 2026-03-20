# Usage:
# make all    -> runs full analysis
# make clean  -> removes generated files

.PHONY: all clean report

all: report

report:
	Rscript -e "rmarkdown::render('analysis.Rmd')"

clean:
	rm -f analysis.html
	rm -rf data/*