#!/usr/bin/env bash
# Search the filesystem for files whose content contains a given word.
#
# Usage: ./search_files.sh [word] [root]
# Defaults to searching for "dog" starting at "/".

set -uo pipefail

word="${1:-dog}"
root="${2:-/}"

# -r recurse, -I skip binary files, -l print only matching filenames.
# Prune virtual/pseudo filesystems that are pointless (and can hang) to search.
grep -rIl \
    --exclude-dir=proc \
    --exclude-dir=sys \
    --exclude-dir=dev \
    --exclude-dir=run \
    -- "$word" "$root" 2>/dev/null
