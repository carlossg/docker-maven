#!/usr/bin/env bash

set -eu
set -o pipefail

. common.sh

for dir in "${all_dirs[@]}"; do
  if [[ "$dir" == *"windows"* ]] || [[ "$dir" == *"nanoserver"* ]]; then
    [[ "$dir" != openjdk-11-windowsservercore ]] && \
      /bin/cp openjdk-11-windowsservercore/mvn-entrypoint.ps1 "$dir/mvn-entrypoint.ps1" && \
      /bin/cp openjdk-11-windowsservercore/settings-docker.xml "$dir/settings-docker.xml"
  else
    [[ "$dir" != openjdk-15 ]] && \
      /bin/cp openjdk-15/mvn-entrypoint.sh "$dir/mvn-entrypoint.sh" && \
      /bin/cp openjdk-15/settings-docker.xml "$dir/settings-docker.xml"
  fi
done

# Download windows jdks, update hash and JAVA_HOME
find . -iname Dockerfile -exec grep -Hl "ARG uri=" {} \; | while read -r file; do
  uri=$(grep "ARG uri=" "$file" | sed -e 's/ARG uri=//')
  zip=$(grep "ARG zip=" "$file" | sed -e 's/ARG zip=//')
  hash=$(grep "ARG hash=" "$file" | sed -e 's/ARG hash=//')
  [[ -f "/tmp/$zip" ]] || curl -sSLf -o "/tmp/$zip" "$uri/$zip"
  IFS=" " read -r -a new_hash <<< "$(sha256sum "/tmp/$zip")"
  echo "$file $uri/$zip $hash ${new_hash[0]}"
  sed -i -e "s/ARG hash=.*/ARG hash=${new_hash[0]}/" "$file"
  java_home="$( (unzip -t "/tmp/$zip" || true) | grep -m 1 "testing: " | sed -e 's#.*testing: \(.*\)/.*#\1#')"
  sed -i -e "s#JAVA_HOME=C.*#JAVA_HOME=C:/ProgramData/${java_home}#" "$file"
done

./generate-stackbrew-library.sh > ../../docker/official-images/library/maven

echo Done, you can submit a PR now to https://github.com/docker-library/official-images
