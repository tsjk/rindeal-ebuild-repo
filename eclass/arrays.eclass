# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: arrays.eclass
# @MAINTAINER:
# Jan Chren (rindeal) <dev.rindeal+gentoo-overlay@gmail.com>
# @BLURB: <SHORT_DESCRIPTION>
# @DESCRIPTION:

if [ -n "${_ARRAYS_ECLASS}" ] ; then
	die "arrays.eclass shouldn't be inheritted multiple times"
fi

case "${EAPI:-0}" in
    6) ;;
    *) die "Unsupported EAPI='${EAPI}' for '${ECLASS}'" ;;
esac

for _v in {,R,P,C}DEPEND_A ; do
	if [[ "$(declare -p ${_v} 2>/dev/null)" == "declare -a"* ]] ; then
		debug-print "Converting ${_v} to ${_v%_A}"
		eval "${_v%_A}+=\" \${${_v}[*]}\""
		debug-print "Unsetting ${_v}"
		unset ${_v}
	fi
done
unset _v

_ARRAYS_ECLASS=1
