HCC=hcc
EXE=

p1$(EXE): p1.hc
	$(HCC) p1.hc -o p1$(EXE)

run-p1: p1.py input.txt
	python p1.py input.txt

run-p2:
	@echo "Visit https://adventofcode.com/2024/day/25 to complete the mission"

.PHONY: run-p1 run-p2