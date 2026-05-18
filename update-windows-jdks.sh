#!/usr/bin/env bash

set -eu
set -o pipefail

. common.sh

tmpdir=./target
mkdir -p "$tmpdir"

find . -iname Dockerfile -exec grep -Hl "ARG uri=" {} \; | while read -r file; do
	uri=$(grep "ARG uri=" "$file" | sed -e 's/ARG uri=//')
	zip=$(grep "ARG zip=" "$file" | sed -e 's/ARG zip=//')
	hash=$(grep "ARG hash=" "$file" | sed -e 's/ARG hash=//')

	remote_file_url="$uri/$zip"
	local_file_path="$tmpdir/$zip"

	echo "Downloading $remote_file_url"
	curl -sSLf -o "$local_file_path" "$remote_file_url"

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
