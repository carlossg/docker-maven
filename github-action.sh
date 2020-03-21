#!/bin/bash -eu

docker_username="${1:-}"
docker_password="${2:-}"

cd "$(dirname "${BASH_SOURCE[0]}")"

. common.sh

DOCKER_REPOSITORY="${DOCKER_REPOSITORY:-csanchez/maven}"
DOCKER_PUSH=${DOCKER_PUSH:-}

# only push from master
branch="${GITHUB_REF##*/}"
echo "Running on branch ${branch}"
if [ "${branch}" != "master" ]; then
    DOCKER_PUSH=""
fi

build-version() {
	local version=$1
	local versionAliases=("${@:2}")
    pushd "$version"
    echo "Building $DOCKER_REPOSITORY:$version"
    docker build -t "$DOCKER_REPOSITORY:$version" .
    if [ -n "$DOCKER_PUSH" ]; then
        echo "Pushing $version"
        docker push "$version"
    fi
    for versionAlias in "${versionAliases[@]}"; do
        echo "Tagging $DOCKER_REPOSITORY:$versionAlias"
        docker tag "$DOCKER_REPOSITORY:$version" "$DOCKER_REPOSITORY:$versionAlias"
        if [ -n "$DOCKER_PUSH" ]; then
            docker push "$DOCKER_REPOSITORY:$versionAlias"
        fi
    done
    popd
}

if [ -n "$DOCKER_PUSH" ]; then
    echo "Docker login"
    echo "${docker_password:?}" | docker login docker.pkg.github.com -u "${docker_username:?}" --password-stdin
fi

versions=( jdk-*/ openjdk-*/ ibmjava-*/ amazoncorretto-*/ azulzulu-*/ )
versions=( "${versions[@]%/}" )

for version in "${versions[@]}"; do
    echo "Building $version"
	mapfile -t versionAliases < <(version-aliases "$version" master)
	build-version "$version" "${versionAliases[@]}"
done
