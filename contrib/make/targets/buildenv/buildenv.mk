
# must be the first target
CMD_ARGUMENTS ?= $(cmd)
# startup script that runs at container start
STARTUP_SCRIPT ?= $(startup)
ifeq ($(DOCKER_ENV),true)
    ifeq ($(shell ${WHICH} docker 2>${DEVNUL}),)
        $(error "docker is not in your system PATH. Please install docker to continue or set DOCKER_ENV = false in make file ")
    endif
    DOCKER_IMAGE ?= $(docker_image)
    DOCKER_CONTAINER_NAME ?=$(container_name)
    DOCKER_CONTAINER_MOUNT_POINT?=$(mount_point)
    ifneq ($(DOCKER_CONTAINER_NAME),)
        CONTAINER_RUNNING := $(shell docker inspect -f '{{.State.Running}}' ${DOCKER_CONTAINER_NAME})
    endif
    ifneq ($(DOCKER_CONTAINER_NAME),)
        DOCKER_IMAGE_EXISTS := $(shell docker images -q ${DOCKER_IMAGE} 2> /dev/null)
    endif
endif

# shell target must be defined first
shell:
ifneq ($(DOCKER_ENV),)
ifeq ($(DOCKER_ENV),true)
    ifeq ($(DOCKER_IMAGE_EXISTS),)
	- @docker pull ${DOCKER_IMAGE}
    endif
    ifneq ($(CONTAINER_RUNNING),true)
	- @docker run --entrypoint "/bin/bash" -v ${CURDIR}:${DOCKER_CONTAINER_MOUNT_POINT} --name ${DOCKER_CONTAINER_NAME} --rm -d -i -t ${DOCKER_IMAGE} -c tail -f /dev/null
    ifneq ($(STARTUP_SCRIPT),)
	- @docker exec --workdir ${DOCKER_CONTAINER_MOUNT_POINT} ${DOCKER_CONTAINER_NAME} /bin/bash -c "${STARTUP_SCRIPT}"
    endif
    endif
endif
endif
ifneq ($(CMD_ARGUMENTS),)
    ifeq ($(DOCKER_ENV),true)
        ifneq ($(DOCKER_ENV),)
	- $(call print_running_env_enter,$(CMD_ARGUMENTS),Docker Container : ${DOCKER_CONTAINER_NAME})
	- @docker exec  --workdir ${DOCKER_CONTAINER_MOUNT_POINT} ${DOCKER_CONTAINER_NAME} /bin/bash -c "$(CMD_ARGUMENTS)"
        endif
    else
	- $(call print_running_env_enter,$(CMD_ARGUMENTS),HOST OS)
ifeq ($(OS),Windows_NT)
	- @CMD /c "$(CMD_ARGUMENTS)"
else
	- @/bin/bash -c "$(CMD_ARGUMENTS)"
endif
    endif
	- $(call print_running_env_exit)
endif

.PHONY: all shell clean-bak
.SILENT: all shell clean-bak

# https://renenyffenegger.ch/notes/development/make/functions/foreach
# https://unix.stackexchange.com/questions/33629/how-can-i-populate-a-file-with-random-data
# https://stackoverflow.com/questions/26554186/with-gnu-make-how-can-i-combine-multiple-files-into-one/26554251
clean-bak:
	- $(call print_running_target)
	- find . -type f -a -name *.bak -exec rm {} \;
	- $(call print_completed_target)
