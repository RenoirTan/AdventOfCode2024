OCAMLC=ocamlc
OCAMLOPTS=-I +str str.cma
EXE=

p1$(EXE): p1.ml
	$(OCAMLC) $(OCAMLOPTS) $^ -o $@

run-p1: p1$(EXE) input.txt
	./p1$(EXE) input.txt

p2$(EXE): p2.ml
	$(OCAMLC) $(OCAMLOPTS) $^ -o $@

run-p2: p2$(EXE) input.txt
	./p2$(EXE) input.txt | grep -C 20 '###############################'

.PHONY: run-p1 run-p2
