#!/usr/bin/env sh

echo "[INFO]: Build all dists."
echo "[INFO]: Working on \"${CI_REGISTRY_IMAGE}\" with ref name \"${CI_COMMIT_REF_NAME}\""

for DIST in ./dists/*; do
	[ -d "${DIST}" ] || continue
	DIST="$(basename "${DIST}")"
	make build REGISTRY_NAME=$CI_REGISTRY_IMAGE DISTRO=${DIST} VERSION=${CI_COMMIT_REF_NAME}-${DIST}
	if [ "$?" -eq "0" ]; then
	    echo "[OK]: The image built successfully."
	    docker images
	else
		echo "[ERROR]: An error occurred in building image."
		docker images
		exit 1
	fi
done