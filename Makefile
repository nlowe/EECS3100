PROJECTS = TestProject
PROJECTS_CLEAN = $(PROJECTS:%=clean-%)

.PHONY: all clean $(PROJECTS) $(PROJECTS_CLEAN)

$(PROJECTS):
	$(MAKE) -C $@

$(PROJECTS_CLEAN):
	$(MAKE) -C $(@:clean-%=%) clean

all: $(PROJECTS)

clean: $(PROJECTS_CLEAN)
