#!/usr/bin/env bash

# Exit script on error
set -o errexit

export FILENAME="$1"
export FILEROOTDIR="${2:-$PROCDIR}"
export FILEPATH=

# expand $FILEROOTDIR in case it is '.'. At the same time make sure through the
# -e flag that the file root directory does exist.
FILEROOTDIR="$(realpath -e "$FILEROOTDIR")"
FILENAME="${FILENAME:-$($GENERATE_RANDOM_NAME)}"
FILEPATH="${FILEROOTDIR}/${FILENAME}"
debug file path "${FILEPATH}"
export FILENAMES_PARSED=0

