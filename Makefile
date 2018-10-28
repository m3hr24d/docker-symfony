REGISTRY_NAME=
VERSION?=latest
DEBUG?=false
PROJECT_NAME?=app
DISTRO=
EXPOSED_PORTS=
APT_CACHER_SERVER=
BASE_IMAGE_FILE=base_image

guard-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Environment variable $* not set"; \
		exit 1; \
	fi

define check_distro_existence
	@ if [ ! -d "./dists/$(DISTRO)" ]; then \
		echo "\"$(DISTRO)\" distribution not exist in this \"dists\" directory!"; \
		exit 2; \
	elif [ ! -f "./dists/$(DISTRO)/$(BASE_IMAGE_FILE)" ]; then \
		echo "\"$(BASE_IMAGE_FILE)\" file not exist in \"$(DISTRO)\" distribution!"; \
		exit 3; \
	fi

	$(eval DISTRO:=$(shell cat "./dists/$(DISTRO)/$(BASE_IMAGE_FILE)"))
	@echo $(DISTRO)
endef

help:
	@echo '           __           __                                     ____                 	  '
	@echo '      ____/ /___  _____/ /_____  _____   _______  ______ ___  / __/___  ____  __  __	  '
	@echo '     / __  / __ \/ ___/ //_/ _ \/ ___/  / ___/ / / / __ `__ \/ /_/ __ \/ __ \/ / / /	  '
	@echo '    / /_/ / /_/ / /__/ ,< /  __/ /     (__  ) /_/ / / / / / / __/ /_/ / / / / /_/ / 	  '
	@echo '    \__,_/\____/\___/_/|_|\___/_/     /____/\__, /_/ /_/ /_/_/  \____/_/ /_/\__, /  	  '
	@echo '                                           /____/                          /____/   	v1'
	@echo ''
	@echo "build REGISTRY_NAME= DISTRO="
	@echo "  Create docker image from specific distro."
	@echo ""
	@echo "release"
	@echo "  push your image to your registry's project."
	@echo ""

build: guard-REGISTRY_NAME guard-VERSION guard-DISTRO
	$(call check_distro_existence)
	@docker tag $(shell cat "./dists/$(DISTRO)/$(BASE_IMAGE_FILE)") base-image
	@docker build --force-rm \
		-t $(REGISTRY_NAME):$(VERSION) \
		--build-arg=DEBUG=$(DEBUG) \
		--build-arg=APT_CACHER_SERVER=$(APT_CACHER_SERVER) \
		--build-arg=PROJECT_NAME=$(PROJECT_NAME) \
		--build-arg=DISTRO=$(DISTRO) \
		--build-arg=EXPOSED_PORTS=$(EXPOSED_PORTS) \
		.

release: guard-REGISTRY_NAME guard-VERSION
	docker push $(REGISTRY_NAME):$(VERSION)
