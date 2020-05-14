#!/bin/bash

# -----------------------------------------------------------------------------
# Find the directory the script is in.
SOURCE="${BASH_SOURCE[0]}"

while [ -h "$SOURCE" ]; do
    DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done

DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

# -----------------------------------------------------------------------------
# Run Julia
time julia --color=yes "--project=$DIR" -e "using Pkg; Pkg.test(;test_args=[\"tesseract\"])"
