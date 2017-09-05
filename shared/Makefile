#
# Shared makefile definitions for all projects. Includes names for assembler, linker, and objcopy binaries
# as well as common flags used for each of these binaries
#
# Also includes targets to make and clean the bootloader
#

AS := arm-none-eabi-as
LD := arm-none-eabi-ld
OBJCOPY := arm-none-eabi-objcopy

ASFLAGS  := -g -mcpu=cortex-m3 -mthumb --fatal-warnings
LDFLAGS  := -T ../shared/device.ld --fatal-warnings --no-undefined --error-unresolved-symbols
OBJFLAGS := -O ihex -R .eeprom

__SELF := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

.PHONY: bootloader clean-bootloader

bootloader:
	$(AS) $(ASFLAGS) -o $(__SELF)boot.o $(__SELF)src/boot.S

clean-bootloader:
	rm -f $(__SELF)boot.o

.DEFAULT_GOAL := default
