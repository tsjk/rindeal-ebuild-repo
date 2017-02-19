#!/bin/bash -

DEFAULT_NAME="Jan Chren (rindeal)"
DEFAULT_EMAIL="dev.rindeal+gentoo-overlay@gmail.com"


format() {
    xmlstarlet fo --indent-spaces 2
}

format_strong() {
    sed 's|^[ \t]*||' |                         # strip leading spaces
    sed -r -e 's:(<[a-z]):\n\1:g' -e 's:([a-z]>):\1\n:g' | # place each element on separate line
    perl -0pe 's/(^.*)\n(^[^<])/\1\2/mg' |      # flatten multiline values
    grep -v '^\s*$' |                           # delete empty lines
    fold -s -w 100 |                            # now fold
    xmlstarlet fo --indent-spaces 2 |           # indent
    perl -0pe 's/^(\s+)(.+\n)(^[^\s<])/\1\2\1  \3/mg'
}

delete_all_maintainers() {
    xmlstarlet ed -d pkgmetadata/maintainer
}

add_myself_as_maintainer() {
    local args=(
        # ensure there is at least one element already in there
        -s 'pkgmetadata' -t elem -n 'tmp'
        # create maintainer element at the firstmost position
        -i 'pkgmetadata/*[1]' -t elem -n 'maintainer'
        # add `type` attribute
        -a 'pkgmetadata/maintainer' -t attr -n 'type' -v 'person'
            # DTD requires this to be the first element
            # create `email` element
            -s 'pkgmetadata/maintainer' -t elem -n 'email' -v "${DEFAULT_EMAIL}"
            # create `name` element
            -s 'pkgmetadata/maintainer' -t elem -n 'name' -v "${DEFAULT_NAME}"
        # delete tmp element
        -d 'pkgmetadata/tmp'
    )
    xmlstarlet ed "${args[@]}"
}

save() {
    local tmp="$(mktemp)"

    echo "${buf}" > "${tmp}" || return 1

    chmod --reference "${file}" "${tmp}" || return 2
    chown --reference "${file}" "${tmp}" || return 3

    mv "${tmp}" "${file}" || return 4
}


file="${1}"
shift
if [ ! -f "${file}" ] ; then
    echo "File: '${file}' doesn't exist'"
    exit 1
fi

if [ $# = 0 ] ; then
    echo "Error: No command specified"
    exit 1
fi


buf="$(< "${file}" )"

while (( $# )) ; do
    cmd="$1"
    shift

    case "${cmd}" in
        f*)
            buf="$( echo "${buf}" | format )"
            ;;
        m*)
            buf="$( echo "${buf}" | add_myself_as_maintainer )"
            ;;
        d*)
            buf="$( echo "${buf}" | delete_all_maintainers )"
            ;;
        s*)
            save
            ;;
        *)
            echo "Unknown command: '${cmd}'"
            exit 1
            ;;
    esac
done


echo "${buf}"
