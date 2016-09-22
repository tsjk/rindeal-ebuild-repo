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


_RINDEAL_ECLASS=1
fi
