#! /bin/bash -e

# Copy files from /usr/share/maven/ref into ${MAVEN_CONFIG}
# So the initial ~/.m2 is set with expected content.
# Don't override, as this is just a reference setup
copy_reference_file() {
  root="${1}"
  f="${2%/}"
  b="${f%.override}"
  echo "$f" >> "$COPY_REFERENCE_FILE_LOG"
  rel="$(echo $f | sed -e "s#${root}##")" # path relative to /usr/share/maven/ref/
  dir=$(dirname "${b}")
  echo " $f -> $rel" >> "$COPY_REFERENCE_FILE_LOG"
  if [[ ! -e ${MAVEN_CONFIG}/${rel} || $f = *.override ]]
  then
    echo "copy $rel to ${MAVEN_CONFIG}" >> "$COPY_REFERENCE_FILE_LOG"
    mkdir -p "${MAVEN_CONFIG}/$(dirname ${rel})"
    cp -r "${f}" "${MAVEN_CONFIG}/${rel}";
  fi;
}
export -f copy_reference_file
touch "${COPY_REFERENCE_FILE_LOG}" || (echo "Can not write to ${COPY_REFERENCE_FILE_LOG}. Wrong volume permissions?" && exit 1)
echo "--- Copying files at $(date)" >> "$COPY_REFERENCE_FILE_LOG"
find /usr/share/maven/ref/ -type f -exec bash -c "copy_reference_file /usr/share/maven/ref/ '{}'" \;

exec "$@"
