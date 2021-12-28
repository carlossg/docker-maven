#!/usr/bin/env bash

set -eu

# Generate one github action for each docker image

. common.sh

for version in "${all_dirs[@]}"; do
    echo "Generating action for $version"
    if [[ "$version" == *"windows"* ]] || [[ "$version" == *"nanoserver"* ]]; then
        sed -e "s/DIRECTORY/$version/" .github/github-action-windows-template.yaml > ".github/workflows/$version.yml"
    else
        sed -e "s/DIRECTORY/$version/" .github/github-action-template.yaml > ".github/workflows/$version.yml"
    fi
done

# Create a workflow for everything else that may be added in a PR
cp .github/github-action-template.yaml .github/workflows/other.yml
for f in *; do
    gsed -i "/DIRECTORY\/\*\*/i \    - '!${f}\/\*\*'" .github/workflows/other.yml
done
gsed -i "s/Docker Maven Image CI DIRECTORY/Docker Maven Image CI other/" .github/workflows/other.yml
gsed -i "/DIRECTORY\/\*\*/,+4 d" .github/workflows/other.yml
