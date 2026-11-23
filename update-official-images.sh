#!/usr/bin/env bash

set -eu
set -o pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

if [ "$#" -gt 2 ]; then
	echo "Usage: $0 [official-images-directory] [report-directory]" >&2
	exit 2
fi

official_images_dir="$(cd "${1:-../../docker/official-images}" && pwd)"
if [ ! -f "$official_images_dir/library/maven" ] || [ "$(git -C "$official_images_dir" rev-parse --show-toplevel)" != "$official_images_dir" ]; then
	echo "Expected an official-images checkout containing library/maven: $official_images_dir" >&2
	exit 1
fi

if ! main_commit="$(git rev-parse --verify 'main^{commit}')"; then
	echo "The Maven checkout must have a local main branch." >&2
	exit 1
fi
if [ "$(git rev-parse HEAD)" != "$main_commit" ]; then
	echo "The Maven checkout must be at the local main revision." >&2
	exit 1
fi

source_status="$(git status --porcelain --untracked-files=normal)"
official_status="$(git -C "$official_images_dir" status --porcelain --untracked-files=normal)"
if [ -n "$source_status" ] || [ -n "$official_status" ]; then
	echo "Both the Maven and official-images checkouts must be clean before running." >&2
	[ -z "$source_status" ] || printf 'Maven:\n%s\n' "$source_status" >&2
	[ -z "$official_status" ] || printf 'official-images:\n%s\n' "$official_status" >&2
	exit 1
fi

if [ "$#" -eq 2 ]; then
	mkdir -p "$2"
	report_dir="$(cd "$2" && pwd)"
else
	report_dir="$(mktemp -d "${TMPDIR:-/tmp}/maven-official-images.XXXXXXXX")"
fi

export OFFICIAL_IMAGES_DIR="$official_images_dir"
export BASHBREW_LIBRARY="$official_images_dir/library"
export PUBLISH_REQUIRE_CLEAN_SOURCE=1

manifest_backup="$(mktemp "${TMPDIR:-/tmp}/maven-manifest.XXXXXXXX")"
if ! cp -p "$official_images_dir/library/maven" "$manifest_backup"; then
	rm -f "$manifest_backup"
	exit 1
fi

cleanup() {
	local status=$?
	trap - EXIT
	if [ "$status" -ne 0 ]; then
		if ! cp -p "$manifest_backup" "$official_images_dir/library/maven"; then
			echo "Failed to restore official-images/library/maven." >&2
			status=1
		fi
	fi
	if ! rm -f "$manifest_backup"; then
		echo "Failed to remove manifest backup: $manifest_backup" >&2
		status=1
	fi
	exit "$status"
}
trap cleanup EXIT

publish_status=0
./publish.sh || publish_status=$?

git status --short | tee "$report_dir/source-status.txt"
git diff HEAD > "$report_dir/source.patch"
git -C "$official_images_dir" diff -- library/maven | tee "$report_dir/official-images.patch"
echo "Report: $report_dir"

if [ "$publish_status" -ne 0 ]; then
	echo "Publishing validation failed; no PR will be created." >&2
	if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
		echo "Publishing validation failed; see the workflow artifact for details." >> "$GITHUB_STEP_SUMMARY"
	fi
	exit "$publish_status"
fi

changed=false
diff_status=0
git -C "$official_images_dir" diff --quiet -- library/maven || diff_status=$?
if [ "$diff_status" -eq 1 ]; then
	changed=true
elif [ "$diff_status" -ne 0 ]; then
	exit "$diff_status"
fi

echo "official-images changes detected: $changed"
if [ -n "${GITHUB_OUTPUT:-}" ]; then
	echo "changed=$changed" >> "$GITHUB_OUTPUT"
fi
if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
	echo "official-images changes detected: $changed. See the workflow artifact for the diff." >> "$GITHUB_STEP_SUMMARY"
fi
