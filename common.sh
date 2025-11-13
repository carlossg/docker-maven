#!/usr/bin/env bash

set -eu

# Default values for 'latest' tag
latestMavenVersion='3.9.11'
latest='25'
default_jdk=eclipse-temurin-$latest-noble

# All the JDKs and their 'latest' tags
parent_images=(eclipse-temurin ibmjava ibm-semeru amazoncorretto libericaopenjdk sapmachine graalvm-community oracle-graalvm)
declare -A jdk_latest=(
	["jdk"]="17"
	["eclipse-temurin"]="$latest-noble"
	["ibmjava"]="8"
	["ibm-semeru"]=""
	["amazoncorretto"]="25"
	["libericaopenjdk"]="17"
	["sapmachine"]="25"
	["graalvm-community"]="25"
	["oracle-graalvm"]="25"
)

# All the directories that have images
all_dirs=(eclipse-temurin-* ibmjava-* ibm-semeru-* amazoncorretto-* azulzulu-* libericaopenjdk-* microsoft-* sapmachine-* graalvm-community-* oracle-graalvm-*)

######################################################################################################################################

# use gnu sed in darwin
if [[ -d /usr/local/opt/gnu-sed/libexec/gnubin ]]; then
	PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
fi

version-aliases() {
	local dir=$1
	local branch=$2

	local dockerfileMavenVersion
	dockerfileMavenVersion="$(grep -m1 'ARG MAVEN_VERSION=' "$dir/Dockerfile" | cut -d'=' -f2)"
	local mavenVersion="${dockerfileMavenVersion}"

	local extraSuffixes=()
	local extraSuffixesString
	extraSuffixesString="$(grep -m1 '# EXTRA_TAG_SUFFIXES=' "$dir/Dockerfile" | cut -d'=' -f2)"
	if [ -n "${extraSuffixesString}" ]; then
		for suffix in ${extraSuffixesString//,/ }; do
			extraSuffixes+=("${suffix}")
		done
	fi

	# dirs with -maven-4 suffix get that removed
	local version="${dir/-maven-4/}"

	local versionAliases=()
	while [ "${mavenVersion%[.-]*}" != "$mavenVersion" ]; do

		# ignore 4.0.0-rc and 4.0.0 versions, we want 4.0.0-rc-5
		if [[ "$mavenVersion" == *"-rc" ]]; then
			# stop the loop
			break
		fi

		versionAliases+=("$mavenVersion-$version")

		# tag 3.5, 3.5.4
		if [[ "$version" == "$default_jdk" ]]; then
			versionAliases+=("$mavenVersion")
		fi
		for parent_image in "${parent_images[@]}"; do
			local parent_image_latest="${jdk_latest[$parent_image]}"
			if [[ "$version" == "$parent_image-${parent_image_latest}" ]]; then
				# tag 3-ibmjava, 3.5-ibmjava, 3.5.4-ibmjava
				versionAliases+=("$mavenVersion-${version//-${parent_image_latest}/}")
			fi
		done

		for extraSuffix in "${extraSuffixes[@]}"; do
			versionAliases+=("${mavenVersion}-${version}-${extraSuffix}")
		done

		# is this a default tag? ie. 3.9-eclipse-temurin-21-noble -> 3.9-eclipse-temurin-21
		if grep -q -m1 '# DEFAULT_FOR_VERSION' "$dir/Dockerfile"; then
			versionAliases+=("$(echo "$mavenVersion-$version" | sed 's/-[^-]*$//')")
		fi

		mavenVersion="${mavenVersion%[.-]*}"
	done

	# do not tag 3, latest, 3-amazoncorretto, amazoncorretto,... if we are not building the latest version
	if [ "$dockerfileMavenVersion" = "$latestMavenVersion" ]; then
		# tag full version
		versionAliases+=("$mavenVersion-$version") # 3-amazoncorretto-11
		for extraSuffix in "${extraSuffixes[@]}"; do
			versionAliases+=("${mavenVersion}-${version}-${extraSuffix}")
		done

		# tag 3, latest
		if [[ "$version" == "$default_jdk" ]]; then
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

		# is this a default tag? ie. 3-eclipse-temurin-21-noble -> 3-eclipse-temurin-21
		if grep -q -m1 '# DEFAULT_FOR_VERSION' "$dir/Dockerfile"; then
			versionAliases+=("$(echo "$mavenVersion-$version" | sed 's/-[^-]*$//')")
		fi
	fi

	printf "%s\n" "${versionAliases[@]}"
}
