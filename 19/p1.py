import sys
from pathlib import Path
from typing import Dict

if len(sys.argv) < 2:
    raise ValueError("No file included!")

with Path(sys.argv[1]).open("r") as f:
    patterns = f.readline().strip().split(", ")
    f.readline()
    designs = list(map(str.strip, f.readlines()))

DP: Dict[str, bool] = {"": True}

def can_make_pattern(design: str) -> bool:
    ok = DP.get(design)
    if ok is not None:
        return ok
    
    def inner(prefix: str) -> bool:
        if not design.startswith(prefix):
            return False
        return can_make_pattern(design[len(prefix):])
    
    ok = any(map(inner, patterns))
    DP[design] = ok
    return ok

allowed = sum(map(lambda d: int(can_make_pattern(d)), designs))
print(allowed)
