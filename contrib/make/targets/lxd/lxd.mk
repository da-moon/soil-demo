
.PHONY: $(LXD_TARGETS)
.SILENT: $(LXD_TARGETS)
$(LXD_TARGETS):
	- $(call print_running_target)
ifeq (, $(shell which sshpass))
 $(error "No 'sshpass' in PATH")
endif
ifeq (, $(shell which jq))
 $(error "No 'jq' in PATH")
endif
	- $(eval name=$(@:lxd-%=%))
	- $(eval command=lxd-debian)
	- $(eval command=$(command) --name '$(name)')
	- $(eval command=$(command) --ssh-config)
	- @$(MAKE) --no-print-directory \
	 -f $(THIS_FILE) shell cmd="${command}"
ifneq ($(DELAY),)
	- sleep $(DELAY)
endif
	- $(call print_completed_target)
.PHONY: $(LXD_START_TARGETS)
.SILENT: $(LXD_START_TARGETS)
$(LXD_START_TARGETS):
	- $(call print_running_target)
	- $(eval name=$(@:lxd-start-%=%))
	- $(call print_running_target, starting $(name))
	- $(eval command=lxc start "$(name)")
	- @$(MAKE) --no-print-directory \
	 -f $(THIS_FILE) shell cmd="${command}"
ifneq ($(DELAY),)
	- sleep $(DELAY)
endif
	- $(call print_completed_target)

.PHONY: lxd-stop
.SILENT: lxd-stop
lxd-stop:
	- $(call print_running_target)
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) $(LXD_STOP_TARGETS)
	- $(call print_completed_target)
.PHONY: $(LXD_STOP_TARGETS)
.SILENT: $(LXD_STOP_TARGETS)
$(LXD_STOP_TARGETS):
	- $(call print_running_target)
	- $(eval name=$(@:lxd-stop-%=%))
	- $(call print_running_target, stopping $(name) LXD container forcefully)
	- $(eval command=lxc stop $(name) --force || true)
	- @$(MAKE) --no-print-directory \
	 -f $(THIS_FILE) shell cmd="${command}"
	- $(call print_completed_target)
.PHONY: lxd-clean
.SILENT: lxd-clean
lxd-clean:
	- $(call print_running_target)
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) $(LXD_CLEAN_TARGETS)
	- $(call print_completed_target)
.PHONY: $(LXD_CLEAN_TARGETS)
.SILENT: $(LXD_CLEAN_TARGETS)
$(LXD_CLEAN_TARGETS):  lxd-clean-%:lxd-stop-%
	- $(call print_running_target)
	- $(eval name=$(@:lxd-clean-%=%))
	- $(call print_running_target, removing $(name) LXD container)
	- $(eval command=lxc delete $(name))
	- @$(MAKE) --no-print-directory \
	 -f $(THIS_FILE) shell cmd="${command}"
	- $(call print_completed_target)
.PHONY: lxd
.SILENT: lxd
lxd:
	- $(call print_running_target)
	- $(info $(LXD_TARGETS))
	- $(info $(LXD_START_TARGETS))
	- $(call print_completed_target)
