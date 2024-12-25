CABAL=cabal

build-p1: app/P1.hs
	$(CABAL) build p1

run-p1: build-p1 app/P1.hs input.txt
	$(CABAL) run p1 input.txt

build-p2: app/P2.hs
	$(CABAL) build p2

run-p2: build-p2 app/P2.hs input.txt
	$(CABAL) run p2 input.txt

.PHONY: build-p1 build-p2 run-p1 run-p2