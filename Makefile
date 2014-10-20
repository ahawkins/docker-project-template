# Original Author: Adam Hawkins
# Original Source: https://github.com/ahawkins/project-template
# See doc/RATIONAL.md for information
# Feel free to modify this file but do not remove this comment.

sha1=$(shell echo $(1) | sha1sum | cut -d ' ' -f 1)

BASE_IMAGES:=ruby:2.1.3 \
						redis:latest 
PULL_BASE_IMAGES:=$(addprefix pull/,$(subst :,_,$(BASE_IMAGES)))
EXPORT_BASE_IMAGES:=$(addprefix export/,$(subst :,_,$(BASE_IMAGES)))
IMPORT_BASE_IMAGES:=$(addprefix import/,$(subst :,_,$(BASE_IMAGES)))

define IMAGE_template
tmp/images/$(call sha1,$(1)):
	docker pull $(1)
	mkdir -p $$(@D)
	docker images -q $(1) > $$@

pull/$(subst :,_,$(1)): tmp/images/$(call sha1,$(1))

tmp/images/$(call sha1,$(1)).tar: tmp/images/$(call sha1,$(1))
	docker save -o $$@ $(1)

export/$(subst :,_,$(1)): tmp/images/$(call sha1,$(1)).tar

import/$(subst :,_,$(1)): tmp/images/$(call sha1,$(1)).tar
	docker load -i $$<

.PHONY: import/$(subst :,_,$(1))
endef

$(foreach image,$(BASE_IMAGES),$(eval $(call IMAGE_template,$(image))))

pull: $(PULL_BASE_IMAGES)
export: $(EXPORT_BASE_IMAGES)
import: $(IMPORT_BASE_IMAGES)

REPO_NAME=example
FIG=fig --project-name $(REPO_NAME)
TAG=$(shell echo $$CIRCLE_SHA1 | cut -c 1-7)

.DEFAULT_GOAL:= build

.PHONY: pull export import environment test test-ci teardown

LINKS=redis
DOCKER_RUN:=docker run -it $(foreach link,$(LINKS),--link $(REPO_NAME)_$(link)_1:$(link))

DOCKER_CONTAINERS=$(shell docker ps -a -q)
DOCKER_IMAGES=$(shell docker images -q)

# Wildcard rule to build an image from a file inside dockerfiles/
# Use the tasks like any other dependency. Order may be controller
# as well.
# See http://www.gnu.org/software/make/manual/make.html#Pattern-Rules
# for info on how this work and what $< and $(@F) mean.
images/% : dockerfiles/% pull
	ln -sf $< Dockerfile
	docker build -t $(REPO_NAME)/$(@F) .
	rm Dockerfile

environment: pull fig.yml
	$(FIG) up -d

build: images/tests

test:
	$(DOCKER_RUN) --rm $(REPO_NAME)/tests

# NOTE: Cannot use --rm on Circle CI, hence the seemingly
# duplicate task.
test-ci: images/tests
	$(DOCKER_RUN) $(REPO_NAME)/tests

teardown:
	$(FIG) stop
	$(FIG) rm --force

# Wildcard rule to push an image from a file inside dockerfiles/
# to the specified registry. Works the same way as above. Used
# in make deploy to push all required images.
push/% : images/%
	ifndef TAG
		$(error "CIRCLE_SHA1 variable missing!")
	endif
	ifndef REGISTRY
		$(error "REGISTRY missing!")
	endif
		docker tag $(REPO_NAME)/$(@F) $(REGISTRY)/$(REPO_NAME)/$(@F):$(TAG)
		docker tag $(REPO_NAME)/$(@F) $(REGISTRY)/$(REPO_NAME)/$(@F):latest
		docker push $(REGISTRY)/$(REPO_NAME)/$(@F)

clean: teardown
	rm -rf tmp/images
ifneq ($(DOCKER_CONTAINERS),)
	docker stop $(DOCKER_CONTAINERS)
	docker rm $(DOCKER_CONTAINERS)
endif
ifneq ($(DOCKER_IMAGES),)
	docker rmi $(DOCKER_IMAGES)
endif
