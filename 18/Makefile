NPM=npm
NPX=npx

node_modules/.package-lock.json:
	$(NPM) install

run-p1: p1.ts input.txt node_modules/.package-lock.json
	$(NPX) ts-node p1.ts input.txt

run-p2: p2.ts input.txt node_modules/.package-lock.json
	$(NPX) ts-node p2.ts input.txt

.PHONY: run-p1 run-p2
