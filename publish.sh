#!/bin/bash -e

for dir in jdk-11 jdk-14 \
  jdk-8-slim jdk-11-slim \
  jdk-8-openj9 jdk-11-openj9 \
  ibmjava-8 ibmjava-8-alpine \
  amazoncorretto-8 azulzulu-11; do
    /bin/cp jdk-8/mvn-entrypoint.sh $dir/mvn-entrypoint.sh
done

./generate-stackbrew-library.sh > ../../docker/official-images/library/maven

echo Done, you can submit a PR now to https://github.com/docker-library/official-images
