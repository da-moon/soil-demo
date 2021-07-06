# OS specific part
# -----------------
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

# nullstring :=
# space := $(nullstring)

null :=
space := ${null} ${null}
P_OP :=(
P_CL :=)

PSEP = $(strip $(SEP))
PROJECT_NAME := $(notdir $(CURDIR))
PWD ?= $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
# ${ } is a space
${space} := ${space}
BLACK = 0
RED = 1
GREEN = 2
YELLOW = 3
BLUE = 4
MShutdownA = 5
CYAN = 6
WHITE = 7

SHELL := /bin/bash
