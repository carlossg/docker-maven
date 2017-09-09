#!/bin/bash
set -e

latest='8'
default_jdk=jdk
variants=( alpine slim )

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
		# tag 3.5, 3.5.0
		if [[ "$version" == *"$default_jdk-$latest" ]]; then
			versionAliases+=( $mavenVersion )
		elif [[ "$version" == *"-$latest" ]]; then
			# tag 3-ibmjava, 3.5-ibmjava, 3.5.0-ibmjava
			versionAliases+=( $mavenVersion-${version//-$latest/} )
		fi
		# tag 3.5-alpine, 3.5.0-alpine, 3.5-slim, 3.5.0-slim
		for variant in "${variants[@]}"; do
			if [[ "$version" == "$default_jdk-$latest-$variant" ]]; then
				versionAliases+=( $mavenVersion-$variant )
			elif [[ "$version" == *"-$latest-$variant" ]]; then
				versionAliases+=( $mavenVersion-${version//-$latest/} )
			fi
		done
		mavenVersion="${mavenVersion%[.-]*}"
	done

	# tag full version
	versionAliases+=( $mavenVersion-$version )

	# tag 3, latest
	if [[ "$version" == "$default_jdk-$latest" ]]; then
		versionAliases+=( $mavenVersion latest )
	elif [[ "$version" == *"-$latest" ]]; then
		# tag 3-ibmjava ibmjava
		versionAliases+=( $mavenVersion-${version//-$latest/} ${version//-$latest/} )
	fi

	# tag alpine, slim
	for variant in "${variants[@]}"; do
		if [[ "$version" == *"$latest-$variant" ]]; then
			if [[ "$version" == "$default_jdk-$latest"* ]]; then
				versionAliases+=( ${version//$default_jdk-$latest-/} )
			else
				versionAliases+=( ${version//-$latest/} )
			fi
		fi
	done
	
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
	branch=master
	generate-version "$version" "$branch"
done
