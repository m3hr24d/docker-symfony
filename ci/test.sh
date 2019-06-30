#!/usr/bin/env sh

echo "[INFO]: Test all dists."
echo "[INFO]: Working on \"${CI_REGISTRY_IMAGE}\" with ref name \"${CI_COMMIT_REF_NAME}\""

for DIST in ./dists/*; do
	[ -d "${DIST}" ] || continue
	DIST="$(basename "${DIST}")"
	IMAGE_NAME=${CI_REGISTRY_IMAGE}:${CI_COMMIT_REF_NAME}-${DIST}
	IMAGE_ID=`docker images -q ${IMAGE_NAME}`
	if [[ ! -z ${IMAGE_ID} ]]; then
		echo "[OK]: The image (${IMAGE_NAME}) found successfully."
	    docker images
	    docker run -d --name ${DIST} ${IMAGE_NAME}
	    IMAGE_STATUS=`docker ps -aq -f status=exited -f name=${DIST}`
	    if [[ -z ${IMAGE_STATUS} ]]; then
			echo "[OK]: The image (${IMAGE_NAME}) has been running since a moment ago."
			docker ps -f name=${DIST}
		else
			echo "[ERROR]: The image (${IMAGE_NAME}) doesn't running."
			docker ps -f name=${DIST}
			exit 1
		fi
	else
		echo "[ERROR]: The image (${IMAGE_NAME}) doesn't exist."
		docker images
		exit 1
	fi
done