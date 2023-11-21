###############################
# Common defaults/definitions #
###############################

comma := ,
empty :=
space := $(empty) $(empty)

# Checks two given strings for equality.
eq = $(if $(or $(1),$(2)),$(and $(findstring $(1),$(2)),\
                                $(findstring $(2),$(1))),1)




######################
# Project parameters #
######################

NAME := roundcube
OWNER := $(or $(GITHUB_REPOSITORY_OWNER),instrumentisto)
REGISTRIES := $(strip $(subst $(comma), ,\
	$(shell grep -m1 'registry: \["' .github/workflows/ci.yml \
	        | cut -d':' -f2 | tr -d '"][')))
ALL_IMAGES := \
	1.6/apache:1.6.5-r3-apache,1.6.5-apache,1.6-apache,1-apache,apache,latest \
	1.6/fpm:1.6.5-r3-fpm,1.6.5-fpm,1.6-fpm,1-fpm,fpm \
	1.5/apache:1.5.6-r3-apache,1.5.6-apache,1.5-apache \
	1.5/fpm:1.5.6-r3-fpm,1.5.6-fpm,1.5-fpm \
	1.4/apache:1.4.15-r3-apache,1.4.15-apache,1.4-apache \
	1.4/fpm:1.4.15-r3-fpm,1.4.15-fpm,1.4-fpm
#	<Dockerfile>:<version>,<tag1>,<tag2>,...

# Default is first image from ALL_IMAGES list.
DOCKERFILE ?= $(word 1,$(subst :, ,$(word 1,$(ALL_IMAGES))))
TAGS ?= $(word 1,$(subst |, ,\
	$(word 2,!$(subst $(DOCKERFILE):, ,$(subst $(space),|,$(ALL_IMAGES))))))
VERSION ?= $(word 1,$(subst -, ,$(TAGS)))-$(word 2,$(subst -, ,$(TAGS)))
ROUNDCUBE_VER ?= $(word 1,$(subst -, ,$(VERSION)))




###########
# Aliases #
###########

dockerfile: codegen.dockerfile

image: docker.image

push: docker.push

release: git.release

tags: docker.tags

test: test.docker




###################
# Docker commands #
###################

docker-registries = $(strip \
	$(or $(subst $(comma), ,$(registries)),$(REGISTRIES)))
docker-tags = $(strip $(or $(subst $(comma), ,$(tags)),$(TAGS)))


# Build Docker image with the given tag.
#
# Usage:
#	make docker.image [tag=($(VERSION)|<docker-tag>)]] [no-cache=(no|yes)]

github_url := $(strip $(or $(GITHUB_SERVER_URL),https://github.com))
github_repo := $(strip $(or $(GITHUB_REPOSITORY),$(OWNER)/$(NAME)-docker-image))

docker.image:
	docker build --network=host --force-rm \
		$(if $(call eq,$(no-cache),yes),--no-cache --pull,) \
		--label org.opencontainers.image.source=$(github_url)/$(github_repo) \
		--label org.opencontainers.image.revision=$(strip \
			$(shell git show --pretty=format:%H --no-patch)) \
		--label org.opencontainers.image.version=$(strip \
			$(shell git describe --tags --dirty \
			            --match='$(word 1,$(subst /, ,$(DOCKERFILE)))*')) \
		-t $(OWNER)/$(NAME):$(or $(tag),$(VERSION)) $(DOCKERFILE)/


# Manually push Docker images to container registries.
#
# Usage:
#	make docker.push [tags=($(TAGS)|<docker-tag-1>[,<docker-tag-2>...])]
#	                 [registries=($(REGISTRIES)|<prefix-1>[,<prefix-2>...])]

docker.push:
	$(foreach tag,$(subst $(comma), ,$(docker-tags)),\
		$(foreach registry,$(subst $(comma), ,$(docker-registries)),\
			$(call docker.push.do,$(registry),$(tag))))
define docker.push.do
	$(eval repo := $(strip $(1)))
	$(eval tag := $(strip $(2)))
	docker push $(repo)/$(OWNER)/$(NAME):$(tag)
endef


# Tag Docker image with the given tags.
#
# Usage:
#	make docker.tags [of=($(VERSION)|<docker-tag>)]
#	                 [tags=($(TAGS)|<docker-tag-1>[,<docker-tag-2>...])]
#	                 [registries=($(REGISTRIES)|<prefix-1>[,<prefix-2>...])]

docker.tags:
	$(foreach tag,$(subst $(comma), ,$(docker-tags)),\
		$(foreach registry,$(subst $(comma), ,$(docker-registries)),\
			$(call docker.tags.do,$(or $(of),$(VERSION)),$(registry),$(tag))))
define docker.tags.do
	$(eval from := $(strip $(1)))
	$(eval repo := $(strip $(2)))
	$(eval to := $(strip $(3)))
	docker tag $(OWNER)/$(NAME):$(from) $(repo)/$(OWNER)/$(NAME):$(to)
endef


# Save Docker images to a tarball file.
#
# Usage:
#	make docker.tar [to-file=(.cache/image.tar|<file-path>)]
#	                [tags=($(VERSION)|<docker-tag-1>[,<docker-tag-2>...])]

docker-tar-file = $(or $(to-file),.cache/image.tar)

docker.tar:
	@mkdir -p $(dir $(docker-tar-file))
	docker save -o $(docker-tar-file) \
		$(foreach tag,$(subst $(comma), ,$(or $(tags),$(VERSION))),\
			$(OWNER)/$(NAME):$(tag))


docker.test: test.docker


# Load Docker images from a tarball file.
#
# Usage:
#	make docker.untar [from-file=(.cache/image.tar|<file-path>)]

docker.untar:
	docker load -i $(or $(from-file),.cache/image.tar)




####################
# Codegen commands #
####################

# Generate Dockerfile from template.
#
# Usage:
#	make dockerfile [dir=(@all|<dockerfile-dir>)]

codegen-dockerfile-dir = $(or $(dir),@all)

codegen.dockerfile:
ifeq ($(codegen-dockerfile-dir),@all)
	$(foreach img,$(ALL_IMAGES),$(call codegen.dockerfile.do,\
		$(word 1,$(subst :, ,$(img))),\
		$(word 1,$(subst $(comma), ,$(word 2,$(subst :, ,$(img)))))))
else
	$(call codegen.dockerfile.do,\
		$(codegen-dockerfile-dir),\
		$(word 1,$(subst -, ,$(word 1,$(subst |, ,\
			$(word 2,!$(subst $(codegen-dockerfile-dir):, ,$(subst $(space),|,\
			                                               $(ALL_IMAGES)))))))))
endif
define codegen.dockerfile.do
	$(eval dockerfile-dir := $(strip $(1)))
	$(eval dockerfile-ver := $(strip $(2)))
	@mkdir -p $(dockerfile-dir)/
	docker run --rm -v "$(PWD)/Dockerfile.tmpl.php":/Dockerfile.php:ro \
		php:alpine php -f /Dockerfile.php -- \
			--dockerfile='$(dockerfile-dir)' \
			--version='$(dockerfile-ver)' \
		> $(dockerfile-dir)/Dockerfile
	@rm -rf $(dockerfile-dir)/rootfs
	cp -rf rootfs $(dockerfile-dir)/
	git add $(dockerfile-dir)/rootfs
endef




####################
# Testing commands #
####################

# Run Bats tests for Docker image.
#
# Documentation of Bats:
#	https://github.com/bats-core/bats-core
#
# Usage:
#	make test.docker [tag=($(VERSION)|<docker-tag>)]

test.docker:
ifeq ($(wildcard node_modules/.bin/bats),)
	@make npm.install
endif
	DOCKERFILE=$(DOCKERFILE) \
	IMAGE=$(OWNER)/$(NAME):$(or $(tag),$(VERSION)) \
	node_modules/.bin/bats \
		--timing $(if $(call eq,$(CI),),--pretty,--formatter tap) \
		--print-output-on-failure \
		tests/main.bats




################
# NPM commands #
################

# Resolve project NPM dependencies.
#
# Usage:
#	make npm.install [dockerized=(no|yes)]

npm.install:
ifeq ($(dockerized),yes)
	docker run --rm --network=host -v "$(PWD)":/app/ -w /app/ \
		node \
			make npm.install dockerized=no
else
	npm install
endif




################
# Git commands #
################

# Release project version (apply version tag and push).
#
# Usage:
#	make git.release [ver=($(VERSION)|<proj-ver>)]

git-release-tag = $(strip $(or $(ver),$(VERSION)))

git.release:
ifeq ($(shell git rev-parse $(git-release-tag) >/dev/null 2>&1 && echo "ok"),ok)
	$(error "Git tag $(git-release-tag) already exists")
endif
	git tag $(git-release-tag) main
	git push origin refs/tags/$(git-release-tag)




##################
# .PHONY section #
##################

.PHONY: dockerfile image push release tags test \
        codegen.dockerfile \
        docker.image docker.push docker.tags docker.tar docker.test \
        docker.untar \
        git.release \
        npm.install \
        test.docker
