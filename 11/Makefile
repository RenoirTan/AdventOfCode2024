RUSTC=rustc
EXE=

p1$(EXE): p1.rs
	rustc $^ -o $@

run-p1: p1$(EXE) input.txt
	./p1$(EXE) input.txt

p2$(EXE): p2.rs
	rustc $^ -o $@

run-p2: p2$(EXE) input.txt
	./p2$(EXE) input.txt

.PHONY: run-p1 run-p2