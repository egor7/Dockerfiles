#!/usr/bin/env bash
#
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2018-10-07 13:57:07 +0100 (Sun, 07 Oct 2018)
#
#  https://github.com/harisekhon/Dockerfiles
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

# Check for new upstream version

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

name="${1:-}"

if [ -z "$name" ]; then
    echo "usage: ${0##*/} <name>"
    exit 1
fi

cd "$srcdir/.."

. "$srcdir/../bash-tools/utils.sh"

versions="$($name/get_versions || :)"

if [ -z "$versions" ]; then
    echo "WARNING: could not determine upstream versions of $name"
fi

latest_version="$(
    sed 's/\./ /g' <<< "$versions" |
    sort -k1n -k2n -k3n |
    sed 's/ /./g' |
    tail -n 1 || :
)"

dockerfile_version="$(
    egrep -i "^ARG .*${name%-*}.*_VERSION=" "$srcdir/../$name/Dockerfile" |
    awk -F= '{print $2}' || :
)"

if [ -z "$dockerfile_version" ]; then
    echo "WARNING: $name: failed to determine Dockerfile version"
fi

if [ "$dockerfile_version" = "$latest_version" ]; then
    echo "$name up-to-date Dockerfile version / latest upstream version = $dockerfile_version / $latest_version"
else
    echo "WARNING: $name: newer version available, current in Dockerfile = $dockerfile_version, latest upstream version = $latest_version"
fi
