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


comma := ,
eq = $(if $(or $(1),$(2)),$(and $(findstring $(1),$(2)),\
                                $(findstring $(2),$(1))),1)

IMAGE_NAME := instrumentisto/roundcube
ALL_IMAGES := \
	1.4/apache:1.4.8-apache,1.4-apache,1-apache,apache,latest \
	1.4/fpm:1.4.8-fpm,1.4-fpm,1-fpm,fpm \
	1.3/apache:1.3.15-apache,1.3-apache \
	1.3/fpm:1.3.15-fpm,1.3-fpm
#	<Dockerfile>:<version>,<tag1>,<tag2>,...

# Default is first image from ALL_IMAGES list.
DOCKERFILE ?= $(word 1,$(subst :, ,$(word 1,$(ALL_IMAGES))))
VERSION ?= $(word 1,$(subst $(comma), ,\
                    $(word 2,$(subst :, ,$(word 1,$(ALL_IMAGES))))))
TAGS ?= $(word 2,$(subst :, ,$(word 1,$(ALL_IMAGES))))



# Build Docker image.
#
# Usage:
#	make image [tag=($(VERSION)|<docker-tag>)] [no-cache=(no|yes)]
#	           [dockerfile=($(DOCKERFILE)|<dockerfile-dir>)]

image-tag = $(if $(call eq,$(tag),),$(VERSION),$(tag))
image-dir = $(if $(call eq,$(dockerfile),),$(DOCKERFILE),$(dockerfile))

image:
	docker build --network=host --force-rm \
		$(if $(call eq,$(no-cache),yes),--no-cache --pull,) \
		-t $(IMAGE_NAME):$(image-tag) $(image-dir)



# Tag Docker image with given tags.
#
# Usage:
#	make tags [for=($(VERSION)|<docker-tag>)]
#	          [tags=($(TAGS)|<docker-tag-1>[,<docker-tag-2>...])]

tags-for = $(if $(call eq,$(for),),$(VERSION),$(for))
tags-tags = $(if $(call eq,$(tags),),$(TAGS),$(tags))

tags:
	$(foreach tag, $(subst $(comma), ,$(tags-tags)),\
		$(call tags.do,$(tags-for),$(tag)))
define tags.do
	$(eval from := $(strip $(1)))
	$(eval to := $(strip $(2)))
	docker tag $(IMAGE_NAME):$(from) $(IMAGE_NAME):$(to)
endef



# Manually push Docker images to Docker Hub.
#
# Usage:
#	make push [tags=($(TAGS)|<docker-tag-1>[,<docker-tag-2>...])]

push-tags = $(if $(call eq,$(tags),),$(TAGS),$(tags))

push:
	$(foreach tag, $(subst $(comma), ,$(push-tags)),\
		$(call push.do, $(tag)))
define push.do
	$(eval tag := $(strip $(1)))
	docker push $(IMAGE_NAME):$(tag)
endef



# Make manual release of Docker images to Docker Hub.
#
# Usage:
#	make release [tag=($(VERSION)|<docker-tag>)] [no-cache=(no|yes)]
#	             [dockerfile=($(DOCKERFILE)|<dockerfile-dir>)]
#	             [tags=($(TAGS)|<docker-tag-1>[,<docker-tag-2>...])]

release:
	@make image dockerfile=$(dockerfile) tag=$(tag) no-cache=$(no-cache)
	@make tags for=$(tag) tags=$(tags)
	@make push tags=$(tags)



# Make manual release of all supported Docker images to Docker Hub.
#
# Usage:
#	make release-all [no-cache=(no|yes)]

release-all:
	$(foreach img,$(ALL_IMAGES),$(call release-all.do,$(img)))
define release-all.do
	$(eval img := $(strip $(1)))
	@make release no-cache=$(no-cache) \
		dockerfile=$(word 1,$(subst :, ,$(img))) \
		tag=$(word 1,$(subst $(comma), ,$(word 2,$(subst :, ,$(img))))) \
		tags=$(word 2,$(subst :, ,$(img)))
endef



# Generate Docker image sources.
#
# Usage:
#	make src [dir=($(DOCKERFILE)|<dockerfile-dir>)]
#	         [tags=($(TAGS)|<docker-tag-1>[,<docker-tag-2>...])]
#	         [ROUNDCUBE_VER=($(VERSION)|<roudcube-version>)]

src: dockerfile post-push-hook



# Generate sources for all supported Docker images.
#
# Usage:
#	make src-all

src-all:
	$(foreach img,$(ALL_IMAGES),$(call src-all.do,$(img)))
define src-all.do
	$(eval img := $(strip $(1)))
	@make src dir=$(word 1,$(subst :, ,$(img))) \
	          tags=$(word 2,$(subst :, ,$(img))) \
	          ROUNDCUBE_VER=$(word 1,$(subst $(comma), ,\
	                                 $(word 2,$(subst :, ,$(img)))))
endef



# Generate Dockerfile from template.
#
# Usage:
#	make dockerfile [dir=($(DOCKERFILE)|<dockerfile-dir>)]
#	                [ROUNDCUBE_VER=($(VERSION)|<roudcube-version>)]

dockerfile-dir = $(if $(call eq,$(dir),),$(DOCKERFILE),$(dir))
dockerfile-ver = $(if $(call eq,$(ROUNDCUBE_VER),),$(VERSION),$(ROUNDCUBE_VER))

dockerfile:
	@mkdir -p $(dockerfile-dir)/
	docker run --rm -v "$(PWD)/Dockerfile.tmpl.php":/Dockerfile.php:ro \
		php:alpine php -f /Dockerfile.php -- \
			--dockerfile='$(dockerfile-dir)' \
			--version='$(dockerfile-ver)' \
		> $(dockerfile-dir)/Dockerfile
	@rm -rf $(dockerfile-dir)/rootfs
	cp -rf rootfs $(dockerfile-dir)/
	git add $(dockerfile-dir)/rootfs



# Generate Dockerfile from template for all supported Docker images.
#
# Usage:
#	make dockerfile-all

dockerfile-all:
	$(foreach img,$(ALL_IMAGES),$(call dockerfile-all.do,$(img)))
define dockerfile-all.do
	$(eval img := $(strip $(1)))
	@make dockerfile dir=$(word 1,$(subst :, ,$(img))) \
	                 ROUNDCUBE_VER=$(word 1,$(subst $(comma), ,\
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
#	make post-push-hook [dir=($(DOCKERFILE)|<dockerfile-dir>)]
#	                    [tags=($(TAGS)|<docker-tag-1>[,<docker-tag-2>...])]

post-push-hook-dir = $(if $(call eq,$(dir),),$(DOCKERFILE),$(dir))
post-push-hook-tags = $(if $(call eq,$(tags),),$(TAGS),$(tags))

post-push-hook:
	@mkdir -p $(post-push-hook-dir)/hooks/
	docker run --rm -v "$(PWD)/post_push.tmpl.php":/post_push.php:ro \
		php:alpine php -f /post_push.php -- \
			--image_tags='$(post-push-hook-tags)' \
		> $(post-push-hook-dir)/hooks/post_push



# Create `post_push` Docker Hub hook for all supported Docker images.
#
# Usage:
#	make post-push-hook-all

post-push-hook-all:
	$(foreach img,$(ALL_IMAGES),$(call post-push-hook-all.do,$(img)))
define post-push-hook-all.do
	$(eval img := $(strip $(1)))
	@make post-push-hook dir=$(word 1,$(subst :, ,$(img))) \
	                     tags=$(word 2,$(subst :, ,$(img)))
endef



# Run tests for Docker image.
#
# Documentation of Bats:
#	https://github.com/bats-core/bats-core
#
# Usage:
#	make test [tag=($(VERSION)|<docker-tag>)]
#	          [dockerfile=($(DOCKERFILE)|<dockerfile-dir>)]

test-tag = $(if $(call eq,$(tag),),$(VERSION),$(tag))
test-dir = $(if $(call eq,$(dockerfile),),$(DOCKERFILE),$(dockerfile))

test:
ifeq ($(wildcard node_modules/.bin/bats),)
	@make deps.bats
endif
	DOCKERFILE=$(test-dir) IMAGE=$(IMAGE_NAME):$(test-tag) \
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
		dockerfile=$(word 1,$(subst :, ,$(img))) \
		tag=$(word 1,$(subst $(comma), ,$(word 2,$(subst :, ,$(img)))))
endef



# Resolve project dependencies for running tests with Yarn.
#
# Usage:
#	make deps.bats

deps.bats:
	docker run --rm --network=host -v "$(PWD)":/app -w /app \
		node:alpine \
			yarn install --non-interactive --no-progress



.PHONY: image tags push \
        release release-all \
        src src-all \
        dockerfile dockerfile-all \
        post-push-hook post-push-hook-all \
        test test-all deps.bats
