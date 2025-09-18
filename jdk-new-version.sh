#!/bin/bash -eu

# Create a new image of each JDK with the new version number

# gnu sed
PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"

from_version="24"
to_version="25"
find . -type d -iname "*${from_version}*" -maxdepth 1 | while read -r dir; do
	dir=${dir#./}
	new_dir="${dir/${from_version}/${to_version}}"
	if [ -d "${new_dir}" ]; then
		echo "${new_dir} -> already exists"
	else
		echo "${dir} -> ${new_dir}"
		cp -a "$dir" "${new_dir}"
		sed -i "s/${from_version}/${to_version}/g" "${new_dir}/Dockerfile"
	fi
done
