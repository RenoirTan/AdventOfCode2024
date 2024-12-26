ZIG=zig
EXE=

zig-out/bin/p1$(EXE): src/p1.zig src/root.zig
	$(ZIG) build

zig-out/bin/p2$(EXE): src/p2.zig src/root.zig
	$(ZIG) build

run-p1: zig-out/bin/p1$(EXE) input.txt
	./zig-out/bin/p1$(EXE) input.txt

run-p2: ./zig-out/bin/p2$(EXE)
	./zig-out/bin/p2$(EXE)

.PHONY: run-p1 run-p2
