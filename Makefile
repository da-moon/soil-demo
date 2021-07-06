include vars.mk
include contrib/make/pkg/base/base.mk
include contrib/make/pkg/string/string.mk
include contrib/make/pkg/color/color.mk
include contrib/make/pkg/functions/functions.mk
include contrib/make/targets/buildenv/buildenv.mk
include contrib/make/targets/git/git.mk
THIS_FILE := $(firstword $(MAKEFILE_LIST))
SELF_DIR := $(dir $(THIS_FILE))
PLAYBOOKS_TARGETS=$(notdir $(patsubst %/,%,$(dir $(wildcard ./playbooks/*/Makefile))))
.PHONY: playbooks
.SILENT: playbooks
playbooks:
	- $(call print_running_target)
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) $(PLAYBOOKS_TARGETS)
	- $(call print_completed_target)

.PHONY: $(PLAYBOOKS_TARGETS)
.SILENT: $(PLAYBOOKS_TARGETS)
$(PLAYBOOKS_TARGETS):
	- $(call print_running_target)
	- @$(MAKE) --no-print-directory -C playbooks/$(@)/ $(@)
	- $(call print_completed_target)

.PHONY: playbooks-info
.SILENT: playbooks-info
playbooks-info:
	- $(info $(PLAYBOOKS_TARGETS))
INVENTORIES_TARGETS=$(PLAYBOOKS_TARGETS:%=%-inventories)
.PHONY: inventories
.SILENT: inventories
inventories:
	- $(call print_running_target)
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) $(INVENTORIES_TARGETS)
	- $(call print_completed_target)
.PHONY: $(INVENTORIES_TARGETS)
.SILENT: $(INVENTORIES_TARGETS)
$(INVENTORIES_TARGETS):
	- $(eval name=$(@:%-inventories=%))
	- @$(MAKE) --no-print-directory -C playbooks/$(name)/ $(name)-inventories

.PHONY: inventories-info
.SILENT: inventories-info
inventories-info:
	- $(info $(INVENTORIES_TARGETS))

CONTAINER_TARGETS=$(PLAYBOOKS_TARGETS:%=%-containers)
.PHONY: containers
.SILENT: containers
containers:
	- $(call print_running_target)
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) $(CONTAINER_TARGETS)
	- $(call print_completed_target)
.PHONY: $(CONTAINER_TARGETS)
.SILENT: $(CONTAINER_TARGETS)
$(CONTAINER_TARGETS):
	- $(eval name=$(@:%-containers=%))
	- @$(MAKE) --no-print-directory -C playbooks/$(name)/ $(name)-containers

TEARDOWN_TARGETS=$(PLAYBOOKS_TARGETS:%=%-teardown)
.PHONY: teardown
.SILENT: teardown
teardown:
	- $(call print_running_target)
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) $(TEARDOWN_TARGETS)
	- $(call print_completed_target)
.PHONY: $(TEARDOWN_TARGETS)
.SILENT: $(TEARDOWN_TARGETS)
$(TEARDOWN_TARGETS):
	- $(eval name=$(@:%-teardown=%))
	- @$(MAKE) --no-print-directory -C playbooks/$(name)/ $(name)-clean

.PHONY: teardown-info
.SILENT: teardown-info
teardown-info:
	- $(info $(TEARDOWN_TARGETS))


.AFTER :
	%if $(MAKESTATUS) == 2
	%echo Make: The final shell line exited with status: $(status)
	%endif
