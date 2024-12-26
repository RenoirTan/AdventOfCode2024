import itertools
import sys
from pathlib import Path
from typing import List, Tuple

import numpy as np

if len(sys.argv) < 2:
    raise ValueError("No file included!")

with Path(sys.argv[1]).open("r") as f:
    raw_schematics = list(map(lambda s: s.split("\n"), f.read().split("\n\n")))

def raw_to_schematic(raw: List[str]) -> Tuple[str, List[int]]:
    side = "lock" if raw[0] == "#####" else "key"
    schematics = []
    for x in range(5):
        for y in range(7):
            if side == "lock" and raw[y][x] == ".":
                schematics.append(y-1)
                break
            elif side == "key" and raw[y][x] == "#":
                schematics.append(6-y)
                break
    return side, schematics

schematics = [raw_to_schematic(r) for r in raw_schematics]
locks = [s for t, s in schematics if t == "lock"]
keys = [s for t, s in schematics if t == "key"]

total = 0
for (lock, key) in itertools.product(locks, keys):
    total += all(((l + k) <= 5 for l, k in zip(lock, key)))

print(total)