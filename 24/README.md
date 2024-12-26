# Explanation for Day 24 Part 2

The series of gates should eventually form a binary adder. To make sure that the adder works, the sequence of inputs to outputs for each bit should match the following diagram below.

![Full Adder Animation](https://upload.wikimedia.org/wikipedia/commons/5/57/Fulladder.gif)

I was initially stumped by this problem, so I took a look online and found out alot of people were displaying the graph and finding discrepancies in the graph. The second option was to isolate which full adders were broken by setting all of the `x` inputs to `1` and `y` to `0`, then checking which of the digits in `z` are 0, starting with the least significant bit. I didn't want to learn how to create a graph in Zig, so brute forcing was the only option. Luckily, there were only 4 swaps, and assuming each swap happened to outputs in the same full-adder, it shouldn't be to difficult to figure out which outputs were swapped, all we have to do is find which full-adders were wrong.

To figure out which adders are not broken, let's reference the full-adder for bit 1, which was not broken.

```
y01 XOR x01 -> gnj (h01)
x01 AND y01 -> ntt (b01)
gnj AND jfw -> spq (c00 AND h01 -> d01)
ntt OR spq -> ndd (b01 OR d01 -> c01)
jfw XOR gnj -> z01 (c00 XOR h01 -> z01)
```

Each full-adder consists of 5 lines. I labelled each of the 5 outputs with their own prefix.

Running the `p1` program on a modified `input.txt`, the output given was `35201543585791` or `0010 0000 0000 0011 1111 1111 1000 0000 0011 1111 1111 1111` in binary. The first `0` was at bit 14. Isolating the gates leading up to bit 14 and its carry flag, it's obvious that `z14` was swapped with `hbk` (corresponding to the carry flag `c14`).

```
y14 XOR x14 -> dfb (h14)
y14 AND x14 -> tck (b14)
bfn AND dfb -> sjr (c13 AND h14 -> d14)
sjr OR tck -> z14
dfb XOR bfn -> hbk (c14)
```

Swapping `z14` and `hbk` to the correct positions, I run `p1` again, giving `35201543831551` or `0010 0000 0000 0011 1111 1111 1000 0011 1111 1111 1111 1111`. This time, the error was at bit 18. The output `z18` appeared in place of the wire corresponding to `b18`. However, because the outputs were all jumbled up, I could not isolate all 5 gates for bit 18, but I knew that `b18` would appear as the output for the equation `c17 XOR h18 -> z18`, so all I had to do was to find the equation where `grp` was one of the arguments for `XOR` and voila... `kvn`.

```
x18 XOR y18 -> grp (h18)
y18 AND x18 -> z18
fgr AND grp -> ffb (d18)
kvn OR ffb -> cjb (c18)
grp XOR fgr -> kvn (b18)
```

Swapping `z18` and `kvn`, the next output was `35201560346623` or `0010 0000 0000 0100 0000 0000 0111 1111 1111 1111 1111 1111`. The next error was at `z23`. This time, `z23` was swapped with `d23`. Since these 2 outputs shared the same 2 arguments, it was easy to deduce what `d23` was.

```
y23 XOR x23 -> rpg (h23)
x23 AND y23 -> gcb (b23)
dvw AND rpg -> z23
jbb OR hpj -> dvw (c23)
dvw XOR rpg -> dbb (d23)
```

After switching `z23` and `dbb`, we get `35201551958015` or `0010 0000 0000 0011 1111 1111 1111 1111 1111 1111 1111 1111`. This time, bit 34 was wrong. This time, the swap was more subtle, `tfn` and `cvh` were wrong. If you compare the outputs and inputs to full-adder 1, you'll notice the discrepancy.

```
x34 XOR y34 -> tfn (b34)
y34 AND x34 -> cvh (h34)
mqf AND cvh -> trj (d34)
tfn OR trj -> cqv (c34)
mqf XOR cvh -> z34
```

Fixing the last pair, we get `35184372088831`, the correct result.

All in all, the answer to part 2 is `cvh,dbb,hbk,kvn,tfn,z14,z18,z23`.