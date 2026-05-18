#!/usr/bin/env bash

set -eu
set -o pipefail

. common.sh

OFFICIAL_IMAGES_DIR=../../docker/official-images

# Images under this prefix build Maven from source in-repo; all other Linux dirs get Dockerfile-template.
from_linux=eclipse-temurin-17-noble

pattern="# common for all images"

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
			# BuildKit does not expand variables in COPY --from=; use a named stage from global ARG+FROM.
			if ! head -20 "$dir/Dockerfile" | grep -q 'AS maven_upstream'; then
				tmpfile="$(mktemp)"
				{
					if [[ "$dir" == *"maven-4"* ]]; then
						echo "FROM maven:${latestMaven4Version}-eclipse-temurin-17 AS maven_upstream"
					else
						echo "FROM maven:${latestMavenVersion}-eclipse-temurin-17 AS maven_upstream"
					fi
					echo ''
					cat "$dir/Dockerfile"
				} >"$tmpfile"
				mv "$tmpfile" "$dir/Dockerfile"
			fi
			# copy from the main Dockerfile template the common lines
			tail -n +2 Dockerfile-template >>"$dir/Dockerfile"
		fi
	fi
done

# Generate GihHub action workflows
./github-action-generation.sh

# Download windows jdks, update hash and JAVA_HOME
./update-windows-jdks.sh

# Replace corretto.key sha
new_sha=$(curl -sSfL https://apt.corretto.aws/corretto.key | sha256sum | awk '{print $1}')
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
