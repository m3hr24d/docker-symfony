REGISTRY_NAME=
VERSION?=latest
DEBUG?=false
PROJECT_NAME?=app
APT_CACHER_SERVER=

guard-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Environment variable $* not set"; \
		exit 1; \
	fi

build: guard-NAME guard-VERSION

	docker build --force-rm \
		-t $(REGISTRY_NAME):$(VERSION) \
		--build-arg=DEBUG=$(DEBUG) \
		--build-arg=APT_CACHER_SERVER=$(APT_CACHER_SERVER) \
		--build-arg=PROJECT_NAME=$(PROJECT_NAME) \
		.

release: guard-NAME guard-VERSION
	docker push $(REGISTRY_NAME):$(VERSION)
