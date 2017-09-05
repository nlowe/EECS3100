# Define the project (final binary name), sources, and intermediate objects
PROJECT := TestProject
SOURCES := $(wildcard src/*.S)
OBJECTS := $(patsubst src/%.S, %.o, $(SOURCES))

# Shared definitions must be included AFTER the project name has been defined
include ../shared/Makefile

# Yo make, these are targets, not files / folders
.PHONY: default link objdump all clean

# Make the 'all' target by default
default: all

# Assemble intermediate objects
%.o: $(SOURCES)
	$(AS) $(ASFLAGS) -o $@ $<

# Link the objects with the bootloader
link: bootloader $(OBJECTS)
	$(LD) $(LDFLAGS) $(OBJECTS)

# Dump a flashable binary from the linked binary
objdump: link
	$(OBJCOPY) $(OBJFLAGS)

# To make 'everything', just invoke the 'objdump' target
all: objdump

# Don't forget to clean the bootloader when cleaning
clean: clean-bootloader
	rm -f *.o *.elf *.bin
