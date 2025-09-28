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

function join_by {
	local d=${1-} f=${2-}
	if shift 2; then
		printf %s "$f" "${@/#/$d}"
	fi
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
	arches=()
	IFS=" " read -r -a arches <<<"$(bashbrew cat --format '{{- join " " .TagEntry.Architectures -}}' "$from")"
	constraints="$(bashbrew cat --format '{{ join ", " .TagEntry.Constraints -}}' "$from")"

	filteredArches=()
	for arch in "${arches[@]}"; do
		# remove i386 from the list of architectures as only imbjava supports it and we are copying
		# the maven commands from eclipse-temurin
		if [[ "${arch}" == "i386" ]]; then
			continue
		fi

		# remove arm32v5, mips64le as it is not supported by eclipse-temurin and getting it from debian-slim
		if [[ "${arch}" == "arm32v5" ]] || [[ "${arch}" == "mips64le" ]]; then
			continue
		fi

		# Amazon Corretto apt does not support arm32v7, ppc64le, s390x, riscv64
		if [[ "${version}" == amazoncorretto-*-debian* ]]; then
			if [[ "${arch}" != "amd64" ]] && [[ "${arch}" != "arm64v8" ]]; then
				continue
			fi
		fi

		# made it past all the filtering, so add the arch to the final list of arches
		filteredArches+=("${arch}")
	done

	echo
	echo "Tags: $(join ', ' "${versionAliases[@]}")"
	echo "Architectures: $(join_by ", " "${filteredArches[@]}")"
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
	# ignore images that can't be official and windows
	ignore_from=(".*windows" "container-registry.oracle.com" "ghcr.io" "mcr.microsoft.com" "azul/" "bellsoft/")
	for ignore in "${ignore_from[@]}"; do
		if grep -q "FROM $ignore" "$version/Dockerfile"; then
			continue 2
		fi
	done

	branch=main
	mapfile -t versionAliases < <(version-aliases "$version" "$branch")
	generate-version "$version" "$branch" "${versionAliases[@]}"
done
