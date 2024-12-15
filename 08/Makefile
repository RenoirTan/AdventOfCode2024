SQL:=sqlite3
SQLEAN_LINUX:=https://github.com/nalgeon/sqlean/releases/download/0.27.1/sqlean-linux-x86.zip

sqlean/sqlean.so:
	wget $(SQLEAN_LINUX)
	unzip sqlean*.zip -d fuck

run-p1: p1.sql run-p1.sh sqlean/sqlean.so
	./run-p1.sh input.txt

run-p2: p2.sql run-p2.sh sqlean/sqlean.so
	./run-p2.sh input.txt

.PHONY: run-p1 run-p2