#!/bin/sh

function everything() {
    for i in {1..24}; do
        day=$(printf "%02d" $i)
        env -C $day/ make run-p1
        env -C $day/ make run-p2
    done
}

everything
