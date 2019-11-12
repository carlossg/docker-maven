#! /bin/sh -eu

# Copy files from /usr/share/maven/ref into ${MAVEN_CONFIG}
# So the initial ~/.m2 is set with expected content.
# Don't override, as this is just a reference setup

copy_reference_files() {
  local log="$MAVEN_CONFIG/copy_reference_file.log"
  local ref="/usr/share/maven/ref"

  if mkdir -p "${MAVEN_CONFIG}/repository" && touch "${log}" > /dev/null 2>&1 ; then
      cd "${ref}"
      local reflink=""
      if cp --help 2>&1 | grep -q reflink ; then
          reflink="--reflink=auto"
      fi
      if [ ! -d "${MAVEN_CONFIG}/repository" -o 1 = "$(find "${MAVEN_CONFIG}/repository" -maxdepth 1 -type d 2>/dev/null | wc -l)" ] ; then
          # destination is empty...
          echo "--- Copying all files to ${MAVEN_CONFIG} at $(date)" >> "${log}"

          local verbose="" # -v is not supported in alpine / busybox
          if cp --help 2>&1 | grep -q "\-v" ; then
              verbose="-v"
          fi

          cp -r ${verbose} ${reflink} . "${MAVEN_CONFIG}" >> "${log}"
      else
          # destination is non-empty, copy file-by-file
          echo "--- Copying individual files to ${MAVEN_CONFIG} at $(date)" >> "${log}"
          find . -type f -exec sh -eu -c '
              log="${1}"
              shift
              reflink="${1}"
              shift
              for f in "$@" ; do
                  if [ ! -e "${MAVEN_CONFIG}/${f}" ] || [ -e "${f}.override" ] ; then
                      mkdir -p "${MAVEN_CONFIG}/$(dirname "${f}")"
                      cp -rv ${reflink} "${f}" "${MAVEN_CONFIG}/${f}" >> "${log}"
                  fi
              done
          ' _ "${log}" "${reflink}" {} +
      fi
      echo >> "${log}"
  else
    echo "Can not write to ${log}. Wrong volume permissions? Carrying on ..."
  fi
}

owd="$(pwd)"
copy_reference_files
unset MAVEN_CONFIG

cd "${owd}"
unset owd

exec "$@"