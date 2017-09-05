# TestProject

A really simple project to test the build system

## Building

Use `make`:

```bash
$ make
arm-none-eabi-as -g -mcpu=cortex-m3 -mthumb --fatal-warnings -o boot.o ../shared/src/boot.S
arm-none-eabi-as -g -mcpu=cortex-m3 -mthumb --fatal-warnings -o main.o src/main.S
arm-none-eabi-ld -T ../shared/device.ld --fatal-warnings --no-undefined --error-unresolved-symbols --require-defined _main -o TestProject.elf boot.o  main.o
arm-none-eabi-objcopy -O ihex -R .eeprom TestProject.elf TestProject.bin
```