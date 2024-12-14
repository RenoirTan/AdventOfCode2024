MCS=mcs
MONO=mono
EXE=.exe

p1$(EXE): p1.cs
	$(MCS) $^ -out:$@

run-p1: p1$(EXE) input.txt
	$(MONO) $^

p2$(EXE): p2.cs
	$(MCS) $^ -out:$@

run-p2: p2$(EXE) input.txt
	$(MONO) $^

.PHONY: run-p1 run-p2