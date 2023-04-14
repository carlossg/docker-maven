#!/usr/bin/env bash

set -eu

cd "$(dirname "${BASH_SOURCE[0]}")"

url='https://github.com/carlossg/docker-maven.git'

. common.sh

# prints "$2$1$3$1...$N"
join() {
	local sep="$1"
	shift
	local out
	printf -v out "${sep//%/%%}%s" "$@"
	echo "${out#$sep}"
}

generate-version() {
	local version=$1
	local branch=$2
	local versionAliases=("${@:3}")
	local commit

	commit="$(git log -1 --format='format:%H' "$branch" -- "$version")"
	if [ -z "$commit" ]; then
		echo >&2 "No commit found for version $version in branch $branch"
		return 1
	fi

	from="$(grep FROM "$version/Dockerfile" | tail -n 1 | awk 'toupper($1) == "FROM" { print $2 }')"
	arches="$(bashbrew cat --format '{{- join ", " .TagEntry.Architectures -}}' "$from")"
	constraints="$(bashbrew cat --format '{{ join ", " .TagEntry.Constraints -}}' "$from")"

	# remove i386 from the list of architectures as only imbjava supports it and we are copying
	# the maven commands from eclipse-temurin
	arches="${arches//i386, /}"
	# remove arm32v5, mips64le as it is not supported by eclipse-temurin and getting it from debian-slim
	arches="${arches//arm32v5, /}"
	arches="${arches//mips64le, /}"

	# Amazon Corretto apt does not support arm32v7, ppc64le, s390x
	if [[ "${version}" == amazoncorretto-*-debian ]]; then
		arches="${arches//arm32v7, /}"
		arches="${arches//ppc64le, /}"
		arches="${arches//s390x, /}"
	fi

	echo
	echo "Tags: $(join ', ' "${versionAliases[@]}")"
	echo "Architectures: $arches"
	[ "$branch" = 'main' ] || echo "GitFetch: refs/heads/$branch"
	echo "GitCommit: $commit"
	echo "Directory: $version"
	[ -z "$constraints" ] || echo "Constraints: $constraints"
}

echo 'Maintainers: Carlos Sanchez <carlos@apache.org> (@carlossg)'
echo 'Builder: buildkit'
echo "GitRepo: $url"
echo 'GitFetch: refs/heads/main'

for version in "${all_dirs[@]}"; do
	# ignore images that can't be official
	if grep -q "FROM mcr.microsoft.com" "$version/Dockerfile"; then
		continue
	fi
	# ignore all windows images
	if grep -q "FROM .*windows" "$version/Dockerfile"; then
		continue
	fi
	if [[ "$version" != azulzulu* ]] && [[ "$version" != liberica* ]]; then
		branch=main
		mapfile -t versionAliases < <(version-aliases "$version" "$branch")
		generate-version "$version" "$branch" "${versionAliases[@]}"
	fi
done
