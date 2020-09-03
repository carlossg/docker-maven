#!/usr/bin/env bash

set -eu

dir="${1:-}"
docker_username="${2:-}"
docker_password="${3:-}"

cd "$(dirname "${BASH_SOURCE[0]}")"

. common.sh

if [ -n "${DOCKER_REPOSITORY:-}" ]; then
    DOCKER_REPOSITORIES=("${DOCKER_REPOSITORY}")
else
    DOCKER_REPOSITORIES=(csanchez/maven ghcr.io/carlossg/maven)
fi
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
    echo "Building docker image: maven:$version"
    docker build -t "maven:$version" .

    if [ -n "$DOCKER_PUSH" ]; then
        for repository in "${DOCKER_REPOSITORIES[@]}"; do
            echo "Pushing $repository:$version"
            docker tag "maven:$version" "$repository:$version"
            docker push "$repository:$version"
        done
    fi
    for versionAlias in "${versionAliases[@]}"; do
        for repository in "${DOCKER_REPOSITORIES[@]}"; do
            echo "Tagging $repository:$versionAlias"
            docker tag "maven:$version" "$repository:$versionAlias"
            if [ -n "$DOCKER_PUSH" ]; then
                echo "Pushing $repository:$versionAlias"
                docker push "$repository:$versionAlias"
            fi
        done
    done
    popd
}

if [ -n "$DOCKER_PUSH" ]; then
    echo "Docker login"
    echo "${docker_password:?}" | docker login -u "${docker_username:?}" --password-stdin
    if [ -n "${CR_PAT:-}" ]; then
        echo "GitHub Container Registry login"
        echo "${CR_PAT}" | docker login ghcr.io -u carlossg --password-stdin
    fi
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

