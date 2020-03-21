#!/bin/bash -eu

latest='14'
default_jdk=jdk
parent_images=( openjdk ibmjava amazoncorretto)
declare -A jdk_latest=( ["jdk"]="14" ["openjdk"]="14" ["ibmjava"]="8" ["amazoncorretto"]="11")
variants=( alpine slim )
declare -A variants_latest=( ["alpine"]="8" ["slim"]="11" )

version-aliases() {
	local version=$1
	local branch=$2

	mavenVersion="$(grep -m1 'ARG MAVEN_VERSION=' "$version/Dockerfile" | cut -d'=' -f2)"

	versionAliases=()
	while [ "${mavenVersion%[.-]*}" != "$mavenVersion" ]; do
		versionAliases+=( "$mavenVersion-$version" )
		# tag 3.5, 3.5.4
		if [[ "$version" == *"$default_jdk-$latest" ]]; then
			versionAliases+=( "$mavenVersion" )
		fi
		for parent_image in "${parent_images[@]}"; do
			local parent_image_latest="${jdk_latest[$parent_image]}"
			if [[ "$version" == "$parent_image-${parent_image_latest}" ]]; then
				# tag 3-ibmjava, 3.5-ibmjava, 3.5.4-ibmjava
				versionAliases+=( "$mavenVersion-${version//-${parent_image_latest}/}" )
			fi
		done

		# tag 3.5-alpine, 3.5.4-alpine, 3.5-slim, 3.5.4-slim
		for variant in "${variants[@]}"; do
			if [[ "$version" == "$default_jdk-${variants_latest[$variant]}-$variant" ]]; then
				versionAliases+=( "$mavenVersion-$variant" )
			elif [[ "$version" == *"-${variants_latest[$variant]}-$variant" ]]; then
				versionAliases+=( "$mavenVersion-${version//-${variants_latest[$variant]}/}" )
			fi
		done
		mavenVersion="${mavenVersion%[.-]*}"
	done

	# tag full version
	versionAliases+=( "$mavenVersion-$version" )

	# tag 3, latest
	if [[ "$version" == "$default_jdk-$latest" ]]; then
		versionAliases+=( "$mavenVersion" latest )
		[ "$branch" = 'master' ] || versionAliases+=( "$branch" )
	fi

	for parent_image in "${parent_images[@]}"; do
		local parent_image_latest="${jdk_latest[$parent_image]}"
		if [[ "$version" == "$parent_image-${parent_image_latest}" ]]; then
			# tag 3-ibmjava ibmjava 3-amazoncorretto amazoncorretto
			versionAliases+=( "$mavenVersion-${version//-$parent_image_latest/}" "${version//-$parent_image_latest/}" )
		fi
	done

	# tag alpine, slim
	for variant in "${variants[@]}"; do
		if [[ "$version" == *"${variants_latest[$variant]}-$variant" ]]; then
			if [[ "$version" == "$default_jdk-${variants_latest[$variant]}"* ]]; then
				versionAliases+=( "${version//$default_jdk-${variants_latest[$variant]}-/}" )
			else
				versionAliases+=( "${version//-${variants_latest[$variant]}/}" )
			fi
		fi
	done
	printf "%s\n" "${versionAliases[@]}"
}
