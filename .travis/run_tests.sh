#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/travis-functions.sh" || exit 1

run_repoman() {
    announce repoman full --xmlparse --verbose --without-mask
}

run_shellcheck() {
    local sc_exclude=(
        SC2034  # unused vars
        SC2086  # double quote
        SC2046  # quote to prevent word splitting
        SC2016  # expressions don't expand in single quotes
    )
    local sc_opts=(
        --shell=bash
        "${sc_exclude[@]/#/--exclude=}"
    )

    # run in a subshell to prevent shopt from leaking
    (
    shopt -s globstar
    echo \$ shellcheck "${sc_opts[@]}" "eclass/*.eclass" "./**/*.ebuild"
    shellcheck "${sc_opts[@]}" eclass/*.eclass ./**/*.ebuild
    )
}

if [[ ${SHELLCHECK} == 1 ]] ; then
    run_shellcheck
else
    run_repoman
fi
