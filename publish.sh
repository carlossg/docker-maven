#!/usr/bin/env bash

set -eu
set -o pipefail

. common.sh

OFFICIAL_IMAGES_DIR=../../docker/official-images

for dir in "${all_dirs[@]}"; do
	if [[ "$dir" == *"windows"* ]] || [[ "$dir" == *"nanoserver"* ]]; then
		from=openjdk-11-windowsservercore
		if [[ "$dir" != "$from" ]]; then
			cp $from/mvn-entrypoint.ps1 "$dir/"
			cp $from/settings-docker.xml "$dir/"
		fi
	else
		from=eclipse-temurin-11
		if [[ "$dir" != "$from" ]]; then
			cp $from/KEYS "$dir/"
			cp $from/mvn-entrypoint.sh "$dir/"
			cp $from/settings-docker.xml "$dir/"
		fi
	fi
done

# Generate GihHub action workflows
./github-action-generation.sh

# Download windows jdks, update hash and JAVA_HOME
find . -iname Dockerfile -exec grep -Hl "ARG uri=" {} \; | while read -r file; do
	uri=$(grep "ARG uri=" "$file" | sed -e 's/ARG uri=//')
	zip=$(grep "ARG zip=" "$file" | sed -e 's/ARG zip=//')
	hash=$(grep "ARG hash=" "$file" | sed -e 's/ARG hash=//')
	if ! [ -f "/tmp/$zip" ]; then
		echo "Downloading: $uri/$zip"
		curl -sSLf -o "/tmp/$zip" "$uri/$zip"
	fi
	IFS=" " read -r -a new_hash <<<"$(sha256sum "/tmp/$zip")"
	echo "$file $uri/$zip $hash ${new_hash[0]}"
	sed -i -e "s/ARG hash=.*/ARG hash=${new_hash[0]}/" "$file"
	echo "Extracting JAVA_HOME from $zip"
	if ! java_home="$( (unzip -t "/tmp/$zip" || true) | grep -m 1 "testing: " | sed -e 's#.*testing: \(.*\)/.*#\1#')"; then
		echo >&2 "Failed to extract JAVA_HOME"
		exit 1
	fi
	echo "Found JAVA_HOME for $zip: $java_home"
	sed -i -e "s#JAVA_HOME=C.*#JAVA_HOME=C:/ProgramData/${java_home}#" "$file"
done

./generate-stackbrew-library.sh >"${OFFICIAL_IMAGES_DIR}/library/maven"

echo "Running naughty"
pushd "${OFFICIAL_IMAGES_DIR}" >/dev/null
./naughty-from.sh maven
popd >/dev/null

echo Done, you can submit a PR now to https://github.com/docker-library/official-images
