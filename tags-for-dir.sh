#!/usr/bin/env bash

set -e

# Generate all the tags for one directory

. common.sh

DOCKER_REPOSITORIES=(
    "${REGISTRY:-ghcr.io}/${IMAGE_NAME:-carlossg/maven}" # GitHub Container Registry
    "${REGISTRY2:-docker.io}/${IMAGE_NAME2:-csanchez/maven}"
)

version="${1:?}"
if [ ! -d "${version}" ]; then
    echo "Directory ${version} does not exist" >&2
    exit 1
fi
mapfile -t versionAliases < <(version-aliases "$version" master)
for versionAlias in "${versionAliases[@]}"; do
    for repository in "${DOCKER_REPOSITORIES[@]}"; do
        echo "$repository:$versionAlias"
    done
done
