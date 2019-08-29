# This Makefile automates possible operations of this project.
#
# Images and description on Docker Hub will be automatically rebuilt on
# pushes to `master` branch of this repo and on updates of parent images.
#
# Note! Docker Hub `post_push` hook must be always up-to-date with default
# values of current Makefile. To update it just use one of:
#	make post-push-hook-all
#	make src-all
#
# It's still possible to build, tag and push images manually. Just use:
#	make release-all


IMAGE_NAME := instrumentisto/roundcube
ALL_IMAGES := \
	1.3/apache:1.3.10-apache,1.3-apache,1-apache,apache,latest \
	1.3/fpm:1.3.10-fpm,1.3-fpm,1-fpm,fpm \
	1.2/apache:1.2.9-apache,1.2-apache \
	1.2/fpm:1.2.9-fpm,1.2-fpm
#	<Dockerfile>:<version>,<tag1>,<tag2>,...


# Default is first image from ALL_IMAGES list.
DOCKERFILE ?= $(word 1,$(subst :, ,$(word 1,$(ALL_IMAGES))))
VERSION ?=  $(word 1,$(subst $(comma), ,\
                     $(word 2,$(subst :, ,$(word 1,$(ALL_IMAGES))))))
TAGS ?= $(word 2,$(subst :, ,$(word 1,$(ALL_IMAGES))))


comma := ,
eq = $(if $(or $(1),$(2)),$(and $(findstring $(1),$(2)),\
                                $(findstring $(2),$(1))),1)



# Build Docker image.
#
# Usage:
#	make image [DOCKERFILE=<dockerfile-dir>]
#	           [VERSION=<image-version>]
#	           [no-cache=(no|yes)]

image:
	docker build --network=host --force-rm \
		$(if $(call eq,$(no-cache),yes),--no-cache --pull,) \
		-t $(IMAGE_NAME):$(VERSION) $(DOCKERFILE)



# Tag Docker image with given tags.
#
# Usage:
#	make tags [VERSION=<image-version>]
#	          [TAGS=<docker-tag-1>[,<docker-tag-2>...]]

tags:
	$(foreach tag,$(subst $(comma), ,$(TAGS)),\
		$(call tags.do,$(VERSION),$(tag)))
define tags.do
	$(eval from := $(strip $(1)))
	$(eval to := $(strip $(2)))
	docker tag $(IMAGE_NAME):$(from) $(IMAGE_NAME):$(to)
endef



# Manually push Docker images to Docker Hub.
#
# Usage:
#	make push [TAGS=<docker-tag-1>[,<docker-tag-2>...]]

push:
	$(foreach tag,$(subst $(comma), ,$(TAGS)),\
		$(call push.do,$(tag)))
define push.do
	$(eval tag := $(strip $(1)))
	docker push $(IMAGE_NAME):$(tag)
endef



# Make manual release of Docker images to Docker Hub.
#
# Usage:
#	make release [DOCKERFILE=<dockerfile-dir>] [no-cache=(no|yes)]
#	             [VERSION=<image-version>]
#	             [TAGS=<docker-tag-1>[,<docker-tag-2>...]]

release: | image tags push



# Make manual release of all supported Docker images to Docker Hub.
#
# Usage:
#	make release-all [no-cache=(no|yes)]

release-all:
	$(foreach img,$(ALL_IMAGES),$(call release-all.do,$(img)))
define release-all.do
	$(eval img := $(strip $(1)))
	@make release no-cache=$(no-cache) \
			DOCKERFILE=$(word 1,$(subst :, ,$(img))) \
			VERSION=$(word 1,$(subst $(comma), ,\
			                 $(word 2,$(subst :, ,$(img))))) \
			TAGS=$(word 2,$(subst :, ,$(img)))
endef



# Generate Docker image sources.
#
# Usage:
#	make src [DOCKERFILE=<dockerfile-dir>] [VERSION=<roudcube-version>]
#	         [TAGS=<docker-tag-1>[,<docker-tag-2>...]]

src: dockerfile post-push-hook



# Generate sources for all supported Docker images.
#
# Usage:
#	make src-all

src-all:
	$(foreach img,$(ALL_IMAGES),$(call src-all.do,$(img)))
define src-all.do
	$(eval img := $(strip $(1)))
	@make src DOCKERFILE=$(word 1,$(subst :, ,$(img))) \
	          VERSION=$(word 1,$(subst $(comma), ,\
	                           $(word 2,$(subst :, ,$(img))))) \
	          TAGS=$(word 2,$(subst :, ,$(img)))
endef



# Generate Dockerfile from template.
#
# Usage:
#	make dockerfile [DOCKERFILE=<dockerfile-dir>]
#	                [VERSION=<roudcube-version>]

dockerfile:
	@mkdir -p $(DOCKERFILE)/
	docker run --rm -v "$(PWD)/Dockerfile.tmpl.php":/Dockerfile.php:ro \
		php:alpine php -f /Dockerfile.php -- \
			--dockerfile='$(DOCKERFILE)' \
			--version='$(VERSION)' \
		> $(DOCKERFILE)/Dockerfile
	@rm -rf $(DOCKERFILE)/rootfs
	cp -rf rootfs $(DOCKERFILE)/
	git add $(DOCKERFILE)/rootfs



# Generate Dockerfile from template for all supported Docker images.
#
# Usage:
#	make dockerfile-all

dockerfile-all:
	$(foreach img,$(ALL_IMAGES),$(call dockerfile-all.do,$(img)))
define dockerfile-all.do
	$(eval img := $(strip $(1)))
	@make dockerfile DOCKERFILE=$(word 1,$(subst :, ,$(img))) \
	                 VERSION=$(word 1,$(subst $(comma), ,\
	                                  $(word 2,$(subst :, ,$(img)))))
endef



# Create `post_push` Docker Hub hook.
#
# When Docker Hub triggers automated build all the tags defined in `post_push`
# hook will be assigned to built image. It allows to link the same image with
# different tags, and not to build identical image for each tag separately.
# See details:
# http://windsock.io/automated-docker-image-builds-with-multiple-tags
#
# Usage:
#	make post-push-hook [DOCKERFILE=<dockerfile-dir>]
#	                    [TAGS=<docker-tag-1>[,<docker-tag-2>...]]

post-push-hook:
	@mkdir -p $(DOCKERFILE)/hooks/
	docker run --rm -v "$(PWD)/post_push.tmpl.php":/post_push.php:ro \
		php:alpine php -f /post_push.php -- \
			--image_tags='$(TAGS)' \
		> $(DOCKERFILE)/hooks/post_push



# Create `post_push` Docker Hub hook for all supported Docker images.
#
# Usage:
#	make post-push-hook-all

post-push-hook-all:
	$(foreach img,$(ALL_IMAGES),$(call post-push-hook-all.do,$(img)))
define post-push-hook-all.do
	$(eval img := $(strip $(1)))
	@make post-push-hook DOCKERFILE=$(word 1,$(subst :, ,$(img))) \
	                     TAGS=$(word 2,$(subst :, ,$(img)))
endef



# Run tests for Docker image.
#
# Documentation of Bats:
#	https://github.com/bats-core/bats-core
#
# Usage:
#	make test [DOCKERFILE=<dockerfile-dir>] [VERSION=<image-version>]

test:
ifeq ($(wildcard node_modules/.bin/bats),)
	@make deps.bats
endif
	DOCKERFILE=$(DOCKERFILE) IMAGE=$(IMAGE_NAME):$(VERSION) \
		node_modules/.bin/bats test/suite.bats



# Run tests for all supported Docker images.
#
# Usage:
#	make test-all [prepare-images=(no|yes)]

test-all:
ifeq ($(prepare-images),yes)
	$(foreach img,$(ALL_IMAGES),\
		$(call test-all.do,image no-cache=$(no-cache),$(img)))
endif
	$(foreach img,$(ALL_IMAGES),\
		$(call test-all.do,test,$(img)))
define test-all.do
	$(eval act := $(strip $(1)))
	$(eval img := $(strip $(2)))
	@make $(act) \
		DOCKERFILE=$(word 1,$(subst :, ,$(img))) \
		VERSION=$(word 1,$(subst $(comma), ,\
		                 $(word 2,$(subst :, ,$(img)))))
endef



# Resolve project dependencies for running tests with Yarn.
#
# Usage:
#	make deps.bats

deps.bats:
	docker run --rm -v "$(PWD)":/app -w /app \
		node:alpine \
			yarn install --non-interactive --no-progress



.PHONY: image tags push \
        release release-all \
        src src-all \
        dockerfile dockerfile-all \
        post-push-hook post-push-hook-all \
        test test-all deps.bats
