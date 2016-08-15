#! /bin/bash -eu

set -o pipefail

# Copy files from /usr/share/maven/ref into ${MAVEN_CONFIG}
# So the initial ~/.m2 is set with expected content.
# Don't override, as this is just a reference setup
copy_reference_file() {
  local root="${1}"
  local f="${2%/}"
  local logfile="${3}"
  local b="${f%.override}"
  local rel
  local dir
  echo "$f" >> "$logfile"
  rel="$(echo $f | sed -e "s#${root}##")" # path relative to /usr/share/maven/ref/
  dir=$(dirname "${b}")
  echo " $f -> $rel" >> "$logfile"
  if [[ ! -e ${MAVEN_CONFIG}/${rel} || $f = *.override ]]
  then
    echo "copy $rel to ${MAVEN_CONFIG}" >> "$logfile"
    mkdir -p "${MAVEN_CONFIG}/$(dirname ${rel})"
    cp -r "${f}" "${MAVEN_CONFIG}/${rel}";
  fi;
}

export -f copy_reference_file
COPY_REFERENCE_FILE_LOG="$MAVEN_CONFIG/copy_reference_file.log"
touch "${COPY_REFERENCE_FILE_LOG}" || (echo "Can not write to ${COPY_REFERENCE_FILE_LOG}. Wrong volume permissions?" && exit 1)
echo "--- Copying files at $(date)" >> "$COPY_REFERENCE_FILE_LOG"
find /usr/share/maven/ref/ -type f -exec bash -c "copy_reference_file /usr/share/maven/ref/ '{}' "$COPY_REFERENCE_FILE_LOG"" \;

exec "$@"
