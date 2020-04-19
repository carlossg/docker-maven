#!/usr/bin/env bash

set -eu

. common.sh

for dir in "${all_dirs[@]}"; do
  [[ "$dir" != openjdk-15 ]] && /bin/cp openjdk-15/mvn-entrypoint.sh "$dir/mvn-entrypoint.sh"
done

./generate-stackbrew-library.sh > ../../docker/official-images/library/maven

echo Done, you can submit a PR now to https://github.com/docker-library/official-images
