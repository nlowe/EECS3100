# ModifiedFib

The Fibonacci sequence, named after Leonardo Bonacci (12th century Italy), is found by starting with the
integers `0` and `1`. These numbers are added to yield the next number, then repeat this process forever
(the upper bound is infinity): The first few numbers in the sequence are `0`, `1`, `1`, `2`, `3`, `5`, `8`,
`13`, `21`.... The ratio of two adjacent members of this sequence `A_i` and `A_i+1` approaches the Golden
Ratio, which is `(1 + sqrt(5))/2` or about `1.618...` (used in architecture as the ratio of the length to
the height of structure0. This project will implement a modified Fibonacci sequence, which is the sequence
the next number is the sum of the previous 3 umbers (instead of the previous 2 numbers). The sequence starts
with `0`, `1`, `1`, ... The sequence is thus:

> `0`, `1`, `1`, `2`, `4`, `7`, `13`, `24`, `44`, ....

## Implementation

The project is implemented in ARM and 16-bit x86 assembly. Specifically, the arm project is built on the
IAR Embeeded Workbench platform, and the x86 project is built on the microsoft MASM assembler.
