#!/usr/bin/env bash
# Updates all files to a new Maven 3.x release.
# Usage: ./update-maven-version.sh [NEW_VERSION]
# If NEW_VERSION is not provided, the latest 3.x release is fetched from Maven Central.
# Exits 0 with no changes if already up to date.

set -euo pipefail

# Use GNU sed on macOS if available (matches common.sh convention)
for gnu_sed in /usr/local/opt/gnu-sed/libexec/gnubin /opt/homebrew/opt/gnu-sed/libexec/gnubin; do
  [ -d "$gnu_sed" ] && PATH="$gnu_sed:$PATH" && break
done

CURRENT=$(grep "latestMavenVersion=" common.sh | cut -d"'" -f2)

if [ $# -ge 1 ]; then
  NEW_VERSION="$1"
else
  NEW_VERSION=$(curl -fsSL https://repo1.maven.org/maven2/org/apache/maven/apache-maven/maven-metadata.xml \
    | grep -oE '<version>3\.[0-9]+\.[0-9]+</version>' \
    | grep -oE '3\.[0-9]+\.[0-9]+' \
    | sort -V | tail -1)
fi

echo "Current: ${CURRENT}"
echo "Latest:  ${NEW_VERSION}"

if [ "${CURRENT}" = "${NEW_VERSION}" ]; then
  echo "Already up to date."
  exit 0
fi

TAR_SHA=$(curl -fsSL "https://downloads.apache.org/maven/maven-3/${NEW_VERSION}/binaries/apache-maven-${NEW_VERSION}-bin.tar.gz.sha512")
ZIP_SHA=$(curl -fsSL "https://downloads.apache.org/maven/maven-3/${NEW_VERSION}/binaries/apache-maven-${NEW_VERSION}-bin.zip.sha512")

OLD_TAR_SHA=$(grep -m1 'ARG SHA=' eclipse-temurin-17-noble/Dockerfile | cut -d'=' -f2)
OLD_ZIP_SHA=$(grep -m1 'ARG SHA=' amazoncorretto-17-windowsservercore/Dockerfile | cut -d'=' -f2)

# Replace version across all Dockerfiles and scripts
find . -name "Dockerfile" -not -path "*/\.*" | xargs sed -i "s/${CURRENT}/${NEW_VERSION}/g"
sed -i "s/${CURRENT}/${NEW_VERSION}/g" common.sh README.md Dockerfile-template github-action.ps1

# Update tar.gz SHA512 in eclipse-temurin-17-noble/Dockerfile (source of truth for Linux images)
sed -i "s/${OLD_TAR_SHA}/${TAR_SHA}/" eclipse-temurin-17-noble/Dockerfile

# Update zip SHA512 in all windowsservercore Dockerfiles (non-maven-4)
for f in amazoncorretto-8-windowsservercore/Dockerfile \
         amazoncorretto-11-windowsservercore/Dockerfile \
         amazoncorretto-17-windowsservercore/Dockerfile \
         azulzulu-11-windowsservercore/Dockerfile \
         azulzulu-17-windowsservercore/Dockerfile; do
  [ -f "$f" ] && sed -i "s/${OLD_ZIP_SHA}/${ZIP_SHA}/" "$f"
done

echo "Updated ${CURRENT} -> ${NEW_VERSION}"
