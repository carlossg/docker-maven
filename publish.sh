#!/usr/bin/env bash

set -eu
set -o pipefail

. common.sh

OFFICIAL_IMAGES_DIR=../../docker/official-images

from_linux=eclipse-temurin-17

pattern="# common for all images"

tmpdir=./target
mkdir -p "$tmpdir"

# we need gnu-sed on macos
if prefix="$(brew --prefix gnu-sed 2>&1)" && [ -d "${prefix}/libexec/gnubin" ]; then
	PATH="${prefix}/libexec/gnubin:$PATH"
fi

for dir in "${all_dirs[@]}"; do
	if [[ "$dir" == *"windows"* ]] || [[ "$dir" == *"nanoserver"* ]]; then
		from=amazoncorretto-17-windowsservercore
		if [[ "$dir" != "$from" ]]; then
			cp $from/mvn-entrypoint.ps1 "$dir/"
			cp $from/settings-docker.xml "$dir/"
		fi
	else
		from=$from_linux
		if [[ "$dir" != "$from"* ]]; then
			# remove everything after the 'common for all images' line
			sed "/^${pattern}$/q" "$dir/Dockerfile" | sponge "$dir/Dockerfile"
			# copy from the main Dockerfile template the common lines
			if [[ "$dir" == *"maven-4"* ]]; then
				tail +2 Dockerfile-template-maven-4 >>"$dir/Dockerfile"
			else
				tail +2 Dockerfile-template >>"$dir/Dockerfile"
			fi
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

	remote_file_url="$uri/$zip"
	local_file_path="$tmpdir/$zip"

	# Download the file if it doesn't exist or is newer
	echo "Downloading $remote_file_url"
	curl -sSLf -z "$local_file_path" -o "$local_file_path.tmp" "$remote_file_url"
	if [ -f "$local_file_path.tmp" ]; then
		echo "Downloaded $remote_file_url"
		mv "$local_file_path.tmp" "$local_file_path"
	else
		echo "File $local_file_path already exists and is not older than the remote file"
	fi

	IFS=" " read -r -a new_hash <<<"$(sha256sum "$local_file_path")"
	echo "$file $uri/$zip $hash ${new_hash[0]}"
	sed -i -e "s/ARG hash=.*/ARG hash=${new_hash[0]}/" "$file"
	echo "Extracting JAVA_HOME from $zip"
	if ! java_home="$( (unzip -t "$local_file_path" || true) | grep -m 1 "testing: " | sed -e 's#.*testing: \(.*\)/.*#\1#')"; then
		echo >&2 "Failed to extract JAVA_HOME"
		exit 1
	fi
	echo "Found JAVA_HOME for $zip: $java_home"
	sed -i -e "s#JAVA_HOME=C.*#JAVA_HOME=C:/ProgramData/${java_home}#" "$file"
done

# Replace corretto.key sha
new_sha=$(curl -sSfL https://apt.corretto.aws/corretto.key | sha256)
find . -maxdepth 2 -name Dockerfile -exec \
	sed -i "s/echo '[0-9a-f]* \*corretto.key' | sha256sum/echo '${new_sha} \*corretto.key' | sha256sum/g" {} \+
echo "Replaced corretto.key SHA in all files."

echo "Generating stackbrew"
./generate-stackbrew-library.sh >"${OFFICIAL_IMAGES_DIR}/library/maven"

echo "Running naughty"
pushd "${OFFICIAL_IMAGES_DIR}" >/dev/null
naughty_output=$(./naughty-from.sh maven)
if [ -n "${naughty_output}" ]; then
	printf "Naughty errors:\n%s\n" "${naughty_output}" >&2
	exit 1
fi
popd >/dev/null

echo Done, you can submit a PR now to https://github.com/docker-library/official-images
