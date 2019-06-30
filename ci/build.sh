#!/usr/bin/env sh

echo "[INFO]: Build all dists."
echo "[INFO]: Working on \"${CI_REGISTRY_IMAGE}\" with ref name \"${CI_COMMIT_REF_NAME}\""

for DIST in ./dists/*; do
	[ -d "${DIST}" ] || continue
	DIST="$(basename "${DIST}")"
	make build REGISTRY_NAME=$CI_REGISTRY_IMAGE DISTRO=${DIST} VERSION=${CI_COMMIT_REF_NAME}-${DIST}
done