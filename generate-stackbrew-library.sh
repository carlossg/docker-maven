#!/usr/local/bin/bash -eu

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

	commit="$(git log -1 --format='format:%H' "$branch" -- "$version")"

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

versions=( jdk-*/ openjdk-*/ ibmjava-*/ amazoncorretto-*/ )
versions=( "${versions[@]%/}" )

for version in "${versions[@]}"; do
	branch=master
	mapfile -t versionAliases < <(version-aliases "$version" "$branch")
	generate-version "$version" "$branch" "${versionAliases[@]}"
done
