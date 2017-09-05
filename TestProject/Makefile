include ../shared/Makefile

PROJECT := TestProject
SOURCES := $(wildcard src/*.S)
OBJECTS := $(patsubst src/%.S, %.o, $(SOURCES))

.PHONY: default link objdump all clean

default: all

%.o: $(SOURCES)
	$(AS) $(ASFLAGS) -o $@ $<

link: bootloader $(OBJECTS)
	$(LD) $(LDFLAGS) -o $(PROJECT).elf ../shared/boot.o $(OBJECTS)

objdump: link
	$(OBJCOPY) $(OBJFLAGS) $(PROJECT).elf $(PROJECT).bin

all: objdump

clean: clean-bootloader
	rm -f *.o *.elf *.bin
