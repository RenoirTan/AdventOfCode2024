R=Rscript

install-deps:
	$(R) -e 'install.packages("readr", repos = "http://cran.us.r-project.org")'
	$(R) -e 'install.packages("collections", repos = "http://cran.us.r-project.org")'

run-p1: p1.r input.txt
	$(R) p1.r input.txt

run-p2: p2.r input.txt
	$(R) p2.r input.txt

.PHONY: install-deps run-p1 run-p2