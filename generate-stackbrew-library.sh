#!/usr/bin/env bash

set -eu

cd "$(dirname "${BASH_SOURCE[0]}")"

url='https://github.com/carlossg/docker-maven.git'

. common.sh

# prints "$2$1$3$1...$N"
join() {
	local sep="$1"; shift
	local out; printf -v out "${sep//%/%%}%s" "$@"
	echo "${out#$sep}"
}

generate-version() {
	local version=$1
	local branch=$2
	local versionAliases=("${@:3}")
	local commit

	commit="$(git log -1 --format='format:%H' "$branch" -- "$version")"
	if [ -z "$commit" ]; then
		echo "No commit found for version $version in branch $branch"
		return 1
	fi

	from="$(awk 'toupper($1) == "FROM" { print $2 }' "$version/Dockerfile")"
	arches="$(bashbrew cat --format '{{- join ", " .TagEntry.Architectures -}}' "$from")"
	constraints="$(bashbrew cat --format '{{ join ", " .TagEntry.Constraints -}}' "$from")"

	echo
	echo "Tags: $(join ', ' "${versionAliases[@]}")"
	echo "Architectures: $arches"
	[ "$branch" = 'master' ] || echo "GitFetch: refs/heads/$branch"
	echo "GitCommit: $commit"
	echo "Directory: $version"
	[ -z "$constraints" ] || echo "Constraints: $constraints"
}

echo 'Maintainers: Carlos Sanchez <carlos@apache.org> (@carlossg)'
echo "GitRepo: $url"

# for backwards compatibility
generate-version openjdk-11 master 3.8.1-jdk-11 3.8-jdk-11 3-jdk-11
generate-version adoptopenjdk-11-openj9 master 3.8.1-jdk-11-openj9 3.8-jdk-11-openj9 3-jdk-11-openj9
generate-version openjdk-11-slim master 3.8.1-jdk-11-slim 3.8-jdk-11-slim 3-jdk-11-slim

generate-version openjdk-8 master 3.8.1-jdk-8 3.8-jdk-8 3-jdk-8
generate-version adoptopenjdk-8-openj9 master 3.8.1-jdk-8-openj9 3.8-jdk-8-openj9 3-jdk-8-openj9
generate-version openjdk-8-slim master 3.8.1-jdk-8-slim 3.8-jdk-8-slim 3-jdk-8-slim

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
		branch=master
		mapfile -t versionAliases < <(version-aliases "$version" "$branch")
		generate-version "$version" "$branch" "${versionAliases[@]}"
	fi
done
