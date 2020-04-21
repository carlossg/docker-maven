#!/usr/bin/env bash

set -eu

dir="${1:-}"
docker_username="${2:-}"
docker_password="${3:-}"

cd "$(dirname "${BASH_SOURCE[0]}")"

. common.sh

DOCKER_REPOSITORY="${DOCKER_REPOSITORY:-csanchez/maven}"
DOCKER_PUSH=${DOCKER_PUSH:-}

# only push from master
ref="${GITHUB_REF:-}"
branch="${ref##*/}"
echo "Running on branch ${branch} (${ref})"
if [ "${branch}" != "master" ]; then
    DOCKER_PUSH=""
fi

build-version() {
	local version=$1
	local versionAliases=("${@:2}")
    pushd "$version"
    echo "Building docker image: $DOCKER_REPOSITORY:$version"
    docker build -t "$DOCKER_REPOSITORY:$version" .
    if [ -n "$DOCKER_PUSH" ]; then
        echo "Pushing $DOCKER_REPOSITORY:$version"
        docker push "$DOCKER_REPOSITORY:$version"
    fi
    for versionAlias in "${versionAliases[@]}"; do
        echo "Tagging $DOCKER_REPOSITORY:$versionAlias"
        docker tag "$DOCKER_REPOSITORY:$version" "$DOCKER_REPOSITORY:$versionAlias"
        if [ -n "$DOCKER_PUSH" ]; then
            echo "Pushing $DOCKER_REPOSITORY:$versionAlias"
            docker push "$DOCKER_REPOSITORY:$versionAlias"
        fi
    done
    popd
}

if [ -n "$DOCKER_PUSH" ]; then
    echo "Docker login"
    echo "${docker_password:?}" | docker login -u "${docker_username:?}" --password-stdin
fi

if [ -z "${dir}" ]; then
    versions=( "${all_dirs[@]}" )
else
    versions=( "${dir}" )
fi

for version in "${versions[@]}"; do
    echo "Building $version"
	mapfile -t versionAliases < <(version-aliases "$version" master)
	build-version "$version" "${versionAliases[@]}"
    echo "Testing $version"
    TAG=$version bats tests
done
