import sys
from pathlib import Path
from typing import Dict

if len(sys.argv) < 2:
    raise ValueError("No file included!")

with Path(sys.argv[1]).open("r") as f:
    patterns = f.readline().strip().split(", ")
    f.readline()
    designs = list(map(str.strip, f.readlines()))

DP: Dict[str, int] = {"": 1}

def count_arrangements(design: str) -> int:
    n = DP.get(design)
    if n is not None:
        return n
    
    def inner(prefix: str) -> int:
        if not design.startswith(prefix):
            return 0
        return count_arrangements(design[len(prefix):])
    
    n = sum(map(inner, patterns))
    DP[design] = n
    return n

n_arrangements = sum(map(count_arrangements, designs))
print(n_arrangements)
