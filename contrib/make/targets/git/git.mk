VERSION   ?= $(shell git describe --tags)
REVISION  ?= $(shell git rev-parse HEAD)
BRANCH    ?= $(shell git rev-parse --abbrev-ref HEAD)
BUILDUSER ?= $(shell id -un)
BUILDTIME ?= $(shell date '+%Y%m%d-%H:%M:%S')
MAJORVERSION ?= $(shell git describe --tags --abbrev=0 | sed s/v// |  awk -F. '{print $$1+1".0.0"}')
MINORVERSION ?= $(shell git describe --tags --abbrev=0 | sed s/v// | awk -F. '{print $$1"."$$2+1".0"}')
PATCHVERSION ?= $(shell git describe --tags --abbrev=0 | sed s/v// | awk -F. '{print $$1"."$$2"."$$3+1}')
.PHONY: git
.SILENT: git
git:
	- $(info VERSION = $(VERSION))
	- $(info REVISION = $(REVISION))
	- $(info BRANCH = $(BRANCH))
	- $(info BUILDUSER = $(BUILDUSER))
	- $(info BUILDTIME = $(BUILDTIME))
	- $(info MAJORVERSION = $(MAJORVERSION))
	- $(info MINORVERSION = $(MINORVERSION))
	- $(info PATCHVERSION = $(PATCHVERSION))
.PHONY: release-major
.SILENT: release-major
release-major:
	- git checkout master
	- git pull
	- git tag -a v$(MAJORVERSION) -m 'release $(MAJORVERSION)'
	- git push origin --tags
.PHONY: release-minor
.SILENT: release-minor
release-minor:
	- git checkout master
	- git pull
	- git tag -a v$(MINORVERSION) -m 'release $(MINORVERSION)'
	- git push origin --tags
.PHONY :release-patch
.SILENT :release-patch
release-patch:
	- git checkout master
	- git pull
	- git tag -a v$(PATCHVERSION) -m 'release $(PATCHVERSION)'
	- git push origin --tags
