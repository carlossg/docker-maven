#!/usr/bin/env bash

set -eu

# Generate one github action for each docker image

. common.sh

for version in "${all_dirs[@]}"; do
    if [[ "$version" != jdk* ]]; then
        echo "Generating action for $version"
        sed -e "s/DIRECTORY/$version/" .github/github-action-template.yaml > ".github/workflows/$version.yml"
    fi
done
