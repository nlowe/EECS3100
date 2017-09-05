AS = arm-none-eabi-as
LD = arm-none-eabi-ld
OBJCOPY = arm-none-eabi-objcopy

ASFLAGS  = -g -mcpu=cortex-m3 -mthumb --fatal-warnings
LDFLAGS  = -T ../shared/device.ld --fatal-warnings --no-undefined --error-unresolved-symbols --require-defined _main -o $(PROJECT).elf
OBJFLAGS = -O ihex -R .eeprom

PROJECT = TestProject
SOURCES := $(wildcard src/*.S)
OBJECTS := $(patsubst src/%.S, %.o, $(SOURCES))

.PHONY: default assemble_boot link objdump all clean

default: all

%.o: $(SOURCES)
	$(AS) $(ASFLAGS) -o $@ $<

assemble_boot:
	$(AS) $(ASFLAGS) -o boot.o ../shared/src/boot.S

link: assemble_boot $(OBJECTS)
	$(LD) $(LDFLAGS) boot.o $(OBJECTS)

objdump: link
	$(OBJCOPY) $(OBJFLAGS) $(PROJECT).elf $(PROJECT).bin

all: objdump

clean:
	-rm -f *.o *.elf *.bin