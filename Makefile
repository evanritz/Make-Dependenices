# .a files are source files (input)
# .b files are dependency files (input/output)
# .c files are "processed" files (output)

include files.mak

.DEFAULT_GOAL=all

PROJECT_SOURCE_FILES=$(SOURCE_FILES) $(AUTO_GENERATED_SOURCE_FILES)
DEPENDENCY_FILES=$(PROJECT_SOURCE_FILES:.a=.b)
PROCESSED_FILES=$(PROJECT_SOURCE_FILES:.a=.c)

include $(DEPENDENCY_FILES)

# arg1 = file to update
# arg2 = any prereqs that could cause the update
define reason_for_update
	if [ ! -f $(1) ]; then echo " it does not exist"; else echo " $(2) changed"; fi
endef

.PHONY: all
all: $(PROCESSED_FILES)
	@echo "Made all!"

.PHONY: clean
clean:
	rm -rf $(AUTO_GENERATED_SOURCE_FILES)
	rm -rf $(DEPENDENCY_FILES)
	rm -rf $(PROCESSED_FILES)

.PHONY: depends
depends: $(DEPENDENCY_FILES)
	@echo "All dependencies updated!"

.PHONY: install
install:

.PHONY: env
env:
	@echo "\$$(PROJECT_SOURCE_FILES) = $(PROJECT_SOURCE_FILES)"
	@echo "\$$(DEPENDENCY_FILES) = $(DEPENDENCY_FILES)"
	@echo "\$$(PROCESSED_FILES) = $(PROCESSED_FILES)"

$(AUTO_GENERATED_SOURCE_FILES): %.a :
	@echo -n "Generating source file $@ because"; $(call reason_for_update, $@, $?)
	@touch $@ || test -e $@

$(DEPENDENCY_FILES): %.b : %.a
	@echo -n "Updating dependency file $@ for $^ because"; $(call reason_for_update, $@, $?)
	@echo "$(basename $@).c: $$(cat $^ | tr '\n' ' ' | tr '.a' '.c')" > $@ \
		|| test -e $@

$(PROCESSED_FILES): %.c : %.a
	@echo -n "Updating processed file $@ for $^ because"; $(call reason_for_update, $@, $?)
	@touch $@ || test -e $@