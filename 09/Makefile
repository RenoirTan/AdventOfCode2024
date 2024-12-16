NASM=nasm
CC=gcc
EXE=

p1.o: p1.s
	$(NASM) -f elf64 $^

p1$(EXE): p1.o
	$(CC) -m64 -no-pie $^ -o $@

p2.o: p2.s
	$(NASM) -f elf64 $^

p2$(EXE): p2.o
	$(CC) -m64 -no-pie $^ -o $@