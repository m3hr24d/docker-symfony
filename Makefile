NAME=registry.gitlab.com/m3hr24d/docker-symfony
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
		-t $(NAME):$(VERSION) \
		--build-arg=DEBUG=$(DEBUG) \
		--build-arg=APT_CACHER_SERVER=$(APT_CACHER_SERVER) \
		--build-arg=PROJECT_NAME=$(PROJECT_NAME) \
		.

release:
	docker push $(NAME):$(VERSION)
