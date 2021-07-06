include vars.mk
include ../../contrib/make/pkg/base/base.mk
include ../../contrib/make/pkg/string/string.mk
include ../../contrib/make/pkg/color/color.mk
include ../../contrib/make/pkg/functions/functions.mk
include ../../contrib/make/targets/buildenv/buildenv.mk
include ../../contrib/make/targets/git/git.mk

THIS_FILE := $(firstword $(MAKEFILE_LIST))
SELF_DIR := $(dir $(THIS_FILE))
.PHONY: $(PROJECT_NAME)
.SILENT: $(PROJECT_NAME)
$(PROJECT_NAME)
	- $(call print_running_target)
	- $(eval command=ansible-playbook -i staging site.yml --limit staging-servers)
	- @$(MAKE) --no-print-directory \
	 -f $(THIS_FILE) shell cmd="${command}"
ifneq ($(DELAY),)
	- sleep $(DELAY)
endif
	- $(call print_completed_target)
