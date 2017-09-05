# A list of projects to build
PROJECTS := TestProject
PROJECTS_CLEAN := $(PROJECTS:%=clean-%)

.PHONY: all clean $(PROJECTS) $(PROJECTS_CLEAN)

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

# No really, the default goal is 'all' please
.DEFAULT_GOAL := all
