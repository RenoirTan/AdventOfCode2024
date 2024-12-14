KOTLINC=kotlinc
KOTLIN=kotlin

P1Kt.class: p1.kt
	$(KOTLINC) $^

run-p1: P1Kt.class input.txt
	$(KOTLIN) $^

P2Kt.class: p2.kt
	$(KOTLINC) $^

run-p2: P2Kt.class input.txt
	$(KOTLIN) $^

.PHONY: run-p1 run-p2