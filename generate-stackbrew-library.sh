#!/bin/bash
set -e

latest='jdk-8'

cd "$(dirname "${BASH_SOURCE[0]}")"

url='git://github.com/carlossg/docker-maven'

generate-version() {
	local version=$1
	local branch=$2
	local branch_suffix=""

	if [ "$branch" != 'master' ]; then
		branch_suffix="-${branch}"
	fi

	commit="$(git log -1 --format='format:%H' "$branch" -- "$version")"
	
	mavenVersion="$(grep -m1 'ARG MAVEN_VERSION=' "$version/Dockerfile" | cut -d'=' -f2)"
	
	versionAliases=()
	while [ "${mavenVersion%[.-]*}" != "$mavenVersion" ]; do
		versionAliases+=( $mavenVersion-$version )
		if [ "$version" = "$latest" ]; then
			versionAliases+=( $mavenVersion )
		fi
		mavenVersion="${mavenVersion%[.-]*}"
	done
	versionAliases+=( $mavenVersion-$version )
	if [ "$version" = "$latest" ]; then
		versionAliases+=( $mavenVersion latest )
	fi
	
	echo
	for va in "${versionAliases[@]}"; do
		if [ "$branch" != 'master' ] && [ "$va" = 'latest' ]; then
			echo "${branch}: ${url}@${commit} $version"
		else
			echo "${va}${branch_suffix}: ${url}@${commit} $version"
		fi
	done
}

echo '# maintainer: Carlos Sanchez <carlos@apache.org> (@carlossg)'

versions=( jdk-*/ ibmjava-*/ )
versions=( "${versions[@]%/}" )

for version in "${versions[@]}"; do
	for branch in master alpine; do
		if ! ( [[ "$version" == "jdk-9" ]] && [ "$branch" == 'alpine' ] ); then # no base image for openjdk-9-alpine yet
			generate-version "$version" "$branch"
		fi
	done
done
