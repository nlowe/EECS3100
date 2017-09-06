# Homework 0

Given a number in the `X` register, perform the following without using `mul` or `div`:

1. Place the value of `X` multiplied by `27` in register `M`
2. Find the quotient and remainder of register `M` divided by `16`
    * Place the quotient in `Q`
    * Place the remainder in `R`
3. Find the parity of `R`
    * Even: Set `P` to `1`
    * Odd: Set `P` to `0`
4. Find the parity of `Q`
    * Even: Set the second bit of `P` to `1`
    * Odd: Set the second bit of `P` to `0`
5. Perform the following actions based on the value of `P` (in base 2)
   * `00`
     * Clear `Y`
     * Clear `Z`
   * `01`
     * Clear `Y`
     * Copy `R` into `Z`
   * `10`
     * Copy `Q` into `Y`
     * Clear `Z`
   * `11`
     * Copy `Q` into `Y`
     * Copy `R` into `Z`

## Implementation Specifics

Use the following registers for implementing the algorithm:

| Psuedo Code | ARM | x86 |
| ----------- | --- | --- |
| `X` | `r1` | Variable `x_var` |
| `M` | `r2` | `AX` |
| `Q` | `r3` | `BX` |
| `R` | `r4` | `CX` |
| `P` | `r5` | `DX` |
| `Y` | `r6` | `SI` |
| `Z` | `r7` | `DI` |

## Building

Use `make` to build the `arm` component:

```bash
$ make
arm-none-eabi-as -g -mcpu=cortex-m3 -mthumb --fatal-warnings -o boot.o ../shared/src/boot.S
arm-none-eabi-as -g -mcpu=cortex-m3 -mthumb --fatal-warnings -o main.o src/main.S
arm-none-eabi-ld -T ../shared/device.ld --fatal-warnings --no-undefined --error-unresolved-symbols --require-defined _main -o TestProject.elf boot.o  main.o
arm-none-eabi-objcopy -O ihex -R .eeprom TestProject.elf TestProject.bin
```

Use `dos.ps1` to build the `x86` component:

```powershell
./dos.ps1
```