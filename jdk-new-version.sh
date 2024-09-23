#!/bin/bash -eu

# Create a new image of each JDK with the new version number

# gnu sed
PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"

from_version="21"
to_version="23"
find . -type d -iname "*${from_version}*" -maxdepth 1 | while read -r dir; do
	dir=${dir#./}
	new_dir="${dir/${from_version}/${to_version}}"
	echo "${dir} -> ${new_dir}"
	cp -a "$dir" "${new_dir}"
	sed -i "s/${from_version}/${to_version}/g" "${new_dir}/Dockerfile"
done
