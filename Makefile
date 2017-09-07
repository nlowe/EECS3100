# A list of projects to build
PROJECTS := TestProject Homework/0
PROJECTS_CLEAN := $(PROJECTS:%=clean-%)

.PHONY: all clean $(PROJECTS) $(PROJECTS_CLEAN) qemu clean-qemu

# For each project, just invoke make recursively
$(PROJECTS):
	$(MAKE) -C $@

# To clean each project, just invoke make recursively with the 'clean' target
$(PROJECTS_CLEAN):
	$(MAKE) -C $(@:clean-%=%) clean

# By default, make all projects
all: $(PROJECTS)

# Clean all projects
clean: $(PROJECTS_CLEAN)

clean-qemu:
	$(MAKE) -C qemu_stm32 clean

qemu:
	cd qemu_stm32 && ./configure --disable-docs --disable-werror --enable-debug --target-list="arm-softmmu" --python=$(shell which python2)
	$(MAKE) -C qemu_stm32 -j

# No really, the default goal is 'all' please
.DEFAULT_GOAL := all
