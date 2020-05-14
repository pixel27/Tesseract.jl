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
# Start a Python HTTP server.
cd "$DIR/docs"

if [[ ! -d "build" ]]; then
    mkdir build
fi

cd build

python3 -m http.server --bind localhost 2> /dev/null &

HTTP_PID="$!"

function terminate() {
    echo
    echo "Stopping HTTP server..."
    kill $HTTP_PID
    wait $HTTP_PID
    rm -rf "$DIR/docs/build"
    exit 0
}
trap terminate SIGINT

cd ..
# -----------------------------------------------------------------------------
# Build the source

while true; do
    clear

    # Build the docs.
    julia --color=yes "--project=$DIR/docs" make.jl nodeploy notest
    echo
    echo "Build complete!"

    # Clean up
    if [[ -d "build" ]]; then
        rm -rf "$DIR/docs/tessdata"
    fi
    if [[ -f "$DIR/docs/sample_es.tiff" ]]; then
        rm "$DIR/docs/sample_es.tiff"
    fi
    if [[ -f "$DIR/docs/sample_fr.tiff" ]]; then
        rm "$DIR/docs/sample_fr.tiff"
    fi
    if [[ -f "$DIR/docs/sample.tiff" ]]; then
        rm "$DIR/docs/sample.tiff"
    fi

    # Wait for a change.
    inotifywait -q -r -e close_write "$DIR/docs/src" "$DIR/src" "$DIR/docs/make.jl"
done


