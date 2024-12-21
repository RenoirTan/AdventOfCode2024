NPM=npm
NPX=npx

node_modules/.package-lock.json:
	$(NPM) install

run-p1: p1.ts input.txt node_modules/.package-lock.json
	$(NPX) ts-node p1.ts input.txt

.PHONY: run-p1