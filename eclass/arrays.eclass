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

for _v in SRC_URI KEYWORDS IUSE {,R,P,C}DEPEND REQUIRED_USE ; do
	if [[ "$(declare -p ${_v}_A 2>/dev/null)" == "declare -a"* ]] ; then
		debug-print "Converting ${_v}_A to ${_v}"
		eval "${_v}+=\" \${${_v}_A[*]}\""
		debug-print "Unsetting ${_v}_A"
		unset ${_v}_A
	fi
done
unset _v

_ARRAYS_ECLASS=1
