#!/bin/bash -eu

# Generate one github action for each docker image

versions=( openjdk-*/ adoptopenjdk-*/ ibmjava-*/ amazoncorretto-*/ azulzulu-*/ )
versions=( "${versions[@]%/}" )

for version in "${versions[@]}"; do
    echo "Generating action for $version"
	sed -e "s/DIRECTORY/$version/" .github/github-action-template.yaml > ".github/workflows/$version.yml"
done
