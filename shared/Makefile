#
# Shared makefile definitions for all projects. Includes names for assembler, linker, and objcopy binaries
# as well as common flags used for each of these binaries
#
# Also includes targets to make and clean the bootloader
#

# We need to know the path to the 'shared' folder for targets made here since we just 'include' the shared makefile
__SELF := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# Shorter names for tools
AS := arm-none-eabi-as
LD := arm-none-eabi-ld
OBJCOPY := arm-none-eabi-objcopy

# Default flags for tools
ASFLAGS  := -g -mcpu=cortex-m3 -mthumb --fatal-warnings
LDFLAGS  := -T ../shared/device.ld --fatal-warnings --no-undefined --error-unresolved-symbols -o $(PROJECT).elf $(__SELF)boot.o
OBJFLAGS := -O ihex -R .eeprom $(PROJECT).elf $(PROJECT).bin

# Yo make, these are targets, not files / folders
.PHONY: bootloader clean-bootloader

# Assemble the bootloader
bootloader:
	$(AS) $(ASFLAGS) -o $(__SELF)boot.o $(__SELF)src/boot.S

# Clean the bootloader
clean-bootloader:
	rm -f $(__SELF)boot.o

# No really, the default goal is 'default' please
.DEFAULT_GOAL := default
