#!/usr/bin/env sh

echo "[INFO]: Build all dists."
echo "[INFO]: Working on \"${CI_REGISTRY_IMAGE}\" with ref name \"${CI_COMMIT_REF_NAME}\""

for DIST in ./dists/*; do
	[ -d "${DIST}" ] || continue
	DIST="$(basename "${DIST}")"
	BASE_IMAGE=`cat ./dists/${DIST}/base_image`
	docker pull ${BASE_IMAGE}
	if [ "$?" -eq "0" ]; then
	    echo "[OK]: Base image pulled successfully."
	    docker images
	else
		echo "[ERROR]: Couldn't pull base image."
		docker images
		exit 1
	fi

	make build REGISTRY_NAME=$CI_REGISTRY_IMAGE DISTRO=${DIST} VERSION=${CI_COMMIT_REF_NAME}-${DIST}
done