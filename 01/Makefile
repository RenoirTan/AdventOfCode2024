CC=gcc
EXE=

p1$(EXE): p1.c
	gcc $^ -o $@

run-p1: p1$(EXE) input.txt
	./p1 input.txt

p2$(EXE): p2.c
	gcc $^ -o $@

run-p2: p2$(EXE) input.txt
	./p2 input.txt

.PHONY: run-p1 run-p2