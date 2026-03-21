.PHONY: all clean

all: analysis.html

analysis.html: analysis.Rmd
	Rscript -e "rmarkdown::render('analysis.Rmd')"

clean:
	rm -f analysis.html
