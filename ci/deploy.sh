#!/usr/bin/env sh

echo "[INFO]: Deploy all dists."
echo "[INFO]: Working on \"${CI_REGISTRY_IMAGE}\" with ref name \"${CI_COMMIT_REF_NAME}\""

for DIST in ./dists/*; do
	[ -d "${DIST}" ] || continue
	DIST="$(basename "${DIST}")"
	make release REGISTRY_NAME=$CI_REGISTRY_IMAGE VERSION=${CI_COMMIT_REF_NAME}-${DIST}
done