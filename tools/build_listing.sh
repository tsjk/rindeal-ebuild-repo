#!/bin/bash

URL_PREFIX="."

cd "$( dirname "${BASH_SOURCE[0]}" )/../"

for cat in *-*/; do
    cat="${cat%/}"
    echo "- [$cat]($URL_PREFIX/$cat)"

    pushd $cat/ >/dev/null 2>&1
    for pn in */; do
        pn="${pn%/}"
        echo "    - [$pn]($URL_PREFIX/$cat/$pn)"
    done
    popd >/dev/null 2>&1

done > LISTING.md
