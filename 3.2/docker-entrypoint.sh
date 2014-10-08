#!/bin/bash
set -e

if [ "$1" = 'mvn' ]; then
  exec /usr/share/maven/bin/mvn "$@"
fi

exec "$@"
