ifeq ($(OS),Windows_NT)
    CLEAR = cls
    LS = dir
    TOUCH =>>
    RM = del /F /Q
    CPF = copy /y
    RMDIR = -RMDIR /S /Q
    MKDIR = -mkdir
    ERRIGNORE = 2>NUL || (exit 0)
    SEP=\\
else
    CLEAR = clear
    LS = ls
    TOUCH = touch
    CPF = cp -f
    RM = rm -rf
    RMDIR = rm -rf
    MKDIR = mkdir -p
    ERRIGNORE = 2>/dev/null
    SEP=/
endif
ifeq ($(findstring cmd.exe,$(SHELL)),cmd.exe)
DEVNUL := NUL
WHICH := where
else
DEVNUL := /dev/null
WHICH := which
endif

null :=
space := ${null} ${null}
P_OP :=(
P_CL :=)

PSEP = $(strip $(SEP))
PWD ?= $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
${space} := ${space}
SHELL := /bin/bash
PROJECT_NAME := $(notdir $(CURDIR))


.PHONY : clean-ssh
.SILENT : clean-ssh
clean-ssh:
	- sed -n -i "/$(PROJECT_NAME)/,/LogLevel/!{//!p}" ~/.ssh/config || true

.PHONY : clean-retry
.SILENT : clean-retry
clean-retry:
	- find . -type f -name '*.retry' -delete

.PHONY : clean-certs
.SILENT : clean-certs
clean-certs:
	- find . -type f -name '*.enc' -delete

.PHONY : vagrant-destroy
.SILENT : vagrant-destroy
vagrant-destroy:
	- vagrant destroy -f || true
	- $(RM) .vagrant

.PHONY : clean
.SILENT : clean
clean: clean-ssh clean-retry clean-certs vagrant-destroy
	- VBoxManage list vms | awk '{print $$1}' | sed 's/"//g' | xargs -r -I {} VBoxManage controlvm {} savestate || true
	- VBoxManage list vms | awk '{print $$1}' | sed 's/"//g' | xargs -r VBoxManage unregistervm --delete || true
	- $(RM) $(PWD)/.vagrant
	- $(RM) $(PWD)/tmp

.PHONY : up
.SILENT : up
up: clean-ssh
	- vagrant up --provider=virtualbox

.PHONY : ssh-config
.SILENT : ssh-config
ssh-config:  up
	- echo '' >> ~/.ssh/config
	- vagrant ssh-config >> ~/.ssh/config
	- sed -i '/^\s*$$/d' ~/.ssh/config
.PHONY : vm
.SILENT : vm
vm: ssh-config
	- $(info VM is ready)
