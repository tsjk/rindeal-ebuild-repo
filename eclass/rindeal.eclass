# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: rindeal.eclass
# @MAINTAINER:
# Jan Chren (rindeal) <dev.rindeal+gentoo-overlay@gmail.com>
# @BLURB: Base eclass that should be inheritted by all ebuilds.
# @DESCRIPTION:

if [ -z "${_RINDEAL_ECLASS}" ] ; then

case "${EAPI:-0}" in
    6) ;;
    *) die "Unsupported EAPI='${EAPI}' for '${ECLASS}'" ;;
esac


## "Command not found" handler
if [[ -z "$(type -t command_not_found_handle 2>/dev/null)" ]] ; then

	command_not_found_handle() {
		debug-print-function "${FUNCNAME}" "$@"
		local -r cmd="${1}"

		## do not die in a pipe
		[[ -t 1 ]] || return 127

		## do not die in a subshell
		read pid cmd state ppid pgrp session tty_nr tpgid rest < /proc/self/stat
		(( $$ == tpgid )) && return 127

		die "'${cmd}': command not found"
	}

else
	debug-print "${ECLASS}: command_not_found_handle() already registered"
fi


epushd() {
	pushd "$@" >/dev/null || die
}

epopd() {
	popd "$@" >/dev/null || die
}


erm() {
	debug-print-function "${FUNCNAME}" "$@"
	local verbose="-v"
	if [[ -n "${RM_V}" && \
		( ! (( RM_V )) || "${RM_V}" == 'false' || "${RM_V}" == 'no' ) \
		]]
	then
		verbose=
	fi

	rm ${verbose} --interactive=never --preserve-root --one-file-system "$@" || die
}


_RINDEAL_ECLASS=1
fi
