#!/usr/bin/env bash

set -eu

# Generate one github action for each docker image

. common.sh

for version in "${all_dirs[@]}"; do
    echo "Generating action for $version"
    if [[ "$version" == *"windows"* ]] || [[ "$version" == *"nanoserver"* ]]; then
        sed -e "s/DIRECTORY/$version/" .github/github-action-windows-template.yaml >".github/workflows/$version.yml"
    else
        sed -e "s/DIRECTORY/$version/" .github/github-action-template.yaml >".github/workflows/$version.yml"
    fi
done
