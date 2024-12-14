JAVAC=javac
JAVA=java

Part1.class: Part1.java
	$(JAVAC) $^

run-p1: Part1.class input.txt
	$(JAVA) Part1 input.txt

Part2.class: Part2.java
	$(JAVAC) $^

run-p2: Part2.class input.txt
	$(JAVA) Part2 input.txt

.PHONY: run-p1 run-p2