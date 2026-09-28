#!/usr/bin/env bash
# Updates all files to a new Maven 3.x or 4.x release.
# Usage: ./update-maven-version.sh [NEW_VERSION]
#   NEW_VERSION: e.g. 3.9.17 or 4.0.0-rc-8. Its major version (3.x vs 4.x)
#                selects which line is updated.
#   "4" alone auto-fetches the latest 4.x (pre-)release, mirroring the
#                no-argument behavior for the 3.x line.
# If NEW_VERSION is not provided, the latest 3.x release is fetched from Maven Central.
# Exits 0 with no changes if already up to date.

set -euo pipefail

# Use GNU sed on macOS if available (matches common.sh convention)
for gnu_sed in /usr/local/opt/gnu-sed/libexec/gnubin /opt/homebrew/opt/gnu-sed/libexec/gnubin; do
  [ -d "$gnu_sed" ] && PATH="$gnu_sed:$PATH" && break
done

ARG="${1:-}"

if [ "$ARG" = "4" ] || [[ "$ARG" == 4.* ]]; then
  MAJOR=4
elif [ -z "$ARG" ] || [[ "$ARG" == 3.* ]]; then
  MAJOR=3
else
  echo "Unrecognized version '${ARG}' (expected a 3.x or 4.x Maven version, or '4' to auto-detect the latest 4.x release)" >&2
  exit 1
fi

if [ "$MAJOR" = 4 ]; then
  VERSION_VAR="latestMaven4Version"
  VERSION_REGEX='4\.[0-9]+\.[0-9]+(-(alpha|beta|rc)-[0-9]+)?'
  DOWNLOAD_PATH="maven-4"
  TAR_SOURCE_DOCKERFILE="eclipse-temurin-17-noble-maven-4/Dockerfile"
  ZIP_SOURCE_DOCKERFILE="amazoncorretto-17-windowsservercore-maven-4/Dockerfile"
  ZIP_DOCKERFILES=(amazoncorretto-17-windowsservercore-maven-4/Dockerfile azulzulu-17-windowsservercore-maven-4/Dockerfile)
  DOCKERFILE_PATH_FILTER=(-path "*-maven-4/Dockerfile")
else
  VERSION_VAR="latestMavenVersion"
  VERSION_REGEX='3\.[0-9]+\.[0-9]+'
  DOWNLOAD_PATH="maven-3"
  TAR_SOURCE_DOCKERFILE="eclipse-temurin-17-noble/Dockerfile"
  ZIP_SOURCE_DOCKERFILE="amazoncorretto-17-windowsservercore/Dockerfile"
  ZIP_DOCKERFILES=(amazoncorretto-8-windowsservercore/Dockerfile
                    amazoncorretto-11-windowsservercore/Dockerfile
                    amazoncorretto-17-windowsservercore/Dockerfile
                    azulzulu-11-windowsservercore/Dockerfile
                    azulzulu-17-windowsservercore/Dockerfile)
  DOCKERFILE_PATH_FILTER=(-not -path "*-maven-4/Dockerfile")
fi

CURRENT=$(grep "${VERSION_VAR}=" common.sh | cut -d"'" -f2)

if [ -n "$ARG" ] && [ "$ARG" != "4" ]; then
  NEW_VERSION="$ARG"
else
  NEW_VERSION=$(curl -fsSL https://repo1.maven.org/maven2/org/apache/maven/apache-maven/maven-metadata.xml \
    | grep -oE "<version>${VERSION_REGEX}</version>" \
    | grep -oE "${VERSION_REGEX}" \
    | sort -V | tail -1)
fi

echo "Current: ${CURRENT}"
echo "Latest:  ${NEW_VERSION}"

if [ "${CURRENT}" = "${NEW_VERSION}" ]; then
  echo "Already up to date."
  exit 0
fi

TAR_SHA=$(curl -fsSL "https://downloads.apache.org/maven/${DOWNLOAD_PATH}/${NEW_VERSION}/binaries/apache-maven-${NEW_VERSION}-bin.tar.gz.sha512")
ZIP_SHA=$(curl -fsSL "https://downloads.apache.org/maven/${DOWNLOAD_PATH}/${NEW_VERSION}/binaries/apache-maven-${NEW_VERSION}-bin.zip.sha512")

OLD_TAR_SHA=$(grep -m1 'ARG SHA=' "$TAR_SOURCE_DOCKERFILE" | cut -d'=' -f2)
OLD_ZIP_SHA=$(grep -m1 'ARG SHA=' "$ZIP_SOURCE_DOCKERFILE" | cut -d'=' -f2)

# Replace version across the relevant Dockerfiles (3.x or 4.x, not both) and common.sh
find . -name "Dockerfile" -not -path "*/\.*" "${DOCKERFILE_PATH_FILTER[@]}" | xargs sed -i "s/${CURRENT}/${NEW_VERSION}/g"
sed -i "s/${CURRENT}/${NEW_VERSION}/g" common.sh

# README.md, Dockerfile-template and github-action.ps1 only reference the 3.x version
if [ "$MAJOR" = 3 ]; then
  sed -i "s/${CURRENT}/${NEW_VERSION}/g" README.md Dockerfile-template github-action.ps1
fi

# Update tar.gz SHA512 in the source-of-truth Dockerfile (builds Maven from source for Linux images)
sed -i "s/${OLD_TAR_SHA}/${TAR_SHA}/" "$TAR_SOURCE_DOCKERFILE"

# Update zip SHA512 in all windowsservercore Dockerfiles for this Maven line
for f in "${ZIP_DOCKERFILES[@]}"; do
  [ -f "$f" ] && sed -i "s/${OLD_ZIP_SHA}/${ZIP_SHA}/" "$f"
done

echo "Updated ${CURRENT} -> ${NEW_VERSION}"
