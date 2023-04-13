#!/usr/bin/env bash

set -eu

# Default values for 'latest' tag
latest='20'
default_jdk=eclipse-temurin

# All the JDKs and their 'latest' tags
parent_images=(openjdk eclipse-temurin ibmjava ibm-semeru amazoncorretto libericaopenjdk sapmachine)
declare -A jdk_latest=(
	["jdk"]="17"
	["openjdk"]=""
	["eclipse-temurin"]=$latest
	["ibmjava"]="8"
	["ibm-semeru"]=""
	["amazoncorretto"]="11"
	["libericaopenjdk"]="17"
	["sapmachine"]="17"
)

# Variants of the JDKs and their 'latest' tag
# do not tag them as it is confusing and requires a lot of maintenance
declare -A extra_tags=(
	# ["eclipse-temurin-17-alpine"]="eclipse-temurin-alpine"
	# ["libericaopenjdk-11-alpine"]="libericaopenjdk-alpine"
	# ["openjdk-18-slim"]="openjdk-slim"
)

# All the directories that have images
all_dirs=(openjdk-* eclipse-temurin-* ibmjava-* ibm-semeru-* amazoncorretto-* azulzulu-* libericaopenjdk-* microsoft-* sapmachine-*)

######################################################################################################################################

# use gnu sed in darwin
if [[ -d /usr/local/opt/gnu-sed/libexec/gnubin ]]; then
	PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
fi

version-aliases() {
	local version=$1
	local branch=$2

	mavenVersion="$(grep -m1 'ARG MAVEN_VERSION=' "$version/Dockerfile" | cut -d'=' -f2)"

	versionAliases=()
	while [ "${mavenVersion%[.-]*}" != "$mavenVersion" ]; do
		versionAliases+=("$mavenVersion-$version")
		# tag 3.5, 3.5.4
		if [[ "$version" == "$default_jdk-$latest" ]]; then
			versionAliases+=("$mavenVersion")
		fi
		for parent_image in "${parent_images[@]}"; do
			local parent_image_latest="${jdk_latest[$parent_image]}"
			if [[ "$version" == "$parent_image-${parent_image_latest}" ]]; then
				# tag 3-ibmjava, 3.5-ibmjava, 3.5.4-ibmjava
				versionAliases+=("$mavenVersion-${version//-${parent_image_latest}/}")
			fi
		done

		# tag eclipse-temurin-8-alpine -> 3.9.1-eclipse-temurin-alpine
		if [ -n "${extra_tags[$version]:-}" ]; then
			versionAliases+=("$mavenVersion-${extra_tags[$version]}")
		fi

		mavenVersion="${mavenVersion%[.-]*}"
	done

	# tag full version
	versionAliases+=("$mavenVersion-$version")

	# tag 3, latest
	if [[ "$version" == "$default_jdk-$latest" ]]; then
		versionAliases+=("$mavenVersion" latest)
		[ "$branch" = 'main' ] || versionAliases+=("$branch")
	fi

	for parent_image in "${parent_images[@]}"; do
		local parent_image_latest="${jdk_latest[$parent_image]}"
		if [[ "$version" == "$parent_image-${parent_image_latest}" ]]; then
			# tag 3-ibmjava ibmjava 3-amazoncorretto amazoncorretto
			versionAliases+=("$mavenVersion-${version//-$parent_image_latest/}" "${version//-$parent_image_latest/}")
		fi
	done

	# extra tags for variants
	if [ -n "${extra_tags[$version]:-}" ]; then
		versionAliases+=("${extra_tags[$version]}")
	fi

	printf "%s\n" "${versionAliases[@]}"
}
