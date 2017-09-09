#
# Shared makefile definitions for all projects. Includes names for assembler, linker, and objcopy binaries
# as well as common flags used for each of these binaries
#
# Also includes targets to make and clean the bootloader
#

# We need to know the path to the 'shared' folder for targets made here since we just 'include' the shared makefile
__SELF := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# Shorter names for tools
PRE := arm-none-eabi-gcc
AS := arm-none-eabi-as
LD := arm-none-eabi-ld
OBJCOPY := arm-none-eabi-objcopy

# Default flags for tools
PREFLAGS := -D __GNU_AS__ -P -CC -traditional-cpp -E
ASFLAGS  := -g -mcpu=cortex-m3 -mthumb --warn --fatal-warnings -mimplicit-it=never
LDFLAGS  := -T $(__SELF)device.ld --fatal-warnings --no-undefined --error-unresolved-symbols -o $(PROJECT).elf $(__SELF)boot.o
OBJFLAGS := -O ihex -R .eeprom $(PROJECT).elf $(PROJECT).bin

define assemble
	$(PRE) $(PREFLAGS) "$(1)" > "$(2)._s"
	$(AS) $(ASFLAGS) -o "$(2)" "$(2)._s"
endef

# Yo make, these are targets, not files / folders
.PHONY: bootloader clean-bootloader

# I don't know why I need this
.PHONY: Makefile Makefile.o ../shared/Makefile ../../shared/Makefile

# Assemble the bootloader
bootloader:
	$(call assemble,$(__SELF)src/boot.S,$(__SELF)boot.o)

# Clean the bootloader
clean-bootloader:
	rm -f $(__SELF)boot.o $(__SELF)boot.o._s

# No really, the default goal is 'default' please
.DEFAULT_GOAL := default
