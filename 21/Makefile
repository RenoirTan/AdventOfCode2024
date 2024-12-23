ERLC=erlc
ESCRIPT=escript

p1.beam: p1.erl
	$(ERLC) $^

run-p1: p1.beam input.txt
	$(ESCRIPT) p1.beam input.txt

p2.beam: p2.erl
	$(ERLC) $^

run-p2: p2.beam input.txt
	$(ESCRIPT) p2.beam input.txt

.PHONY: run-p1 run-p2