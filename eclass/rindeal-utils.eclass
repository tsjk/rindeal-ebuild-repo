# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: rindeal-utils.eclass
# @MAINTAINER:
# Jan Chren (rindeal) <dev.rindeal+gentoo-overlay@gmail.com>
# @BLURB: Collection of handy functions for my overlay
# @DESCRIPTION:

if [ -z "${_RINDEAL_UTILS_ECLASS}" ] ; then

case "${EAPI:-0}" in
    6) ;;
    *) die "Unsupported EAPI='${EAPI}' for '${ECLASS}'" ;;
esac


# DESCRIPTION:
#	Dependency Specification Format is missing "or"ing of USE flags, so this function works around it
# USAGE:
# 	'a b c'		x y z
# 	'a | b | c'	x y z
# 	'a|b|c'		x y z
# 	'a || b || c'	x y z
rindeal::dsf::or() {
	local cond ret=''
	IFS='||' read -r -a cond <<< "$1"
	shift

	local c
	for c in ${cond[*]} ; do
		# unquoted $* ensures, whitespaces won't get through
		ret+="${c}? ( $* )"$'\n'
	done

	echo "${ret}"
}

rindeal::expand_vars() {
	local f_in="${1}"
	local f_out="${2}"
	(( $# > 2 || $# < 1 )) && die

	local sed_args=()
	local v vars=( $( grep -Eo '@[A-Z0-9_]+@' -- "${f_in}" | tr -d '@') )
	for v in "${vars[@]}" ; do
		if [[ -v "${v}" ]] ; then
			sed_args+=( -e "s|@${v}@|${!v}|g" )
		else
			einfo "${FUNCNAME}: var '${v}' doesn't exist"
		fi
	done

	local basedir="$(dirname "${WORKDIR}")"
	echo "Converting '${f_in#"${basedir}/"}' -> '${f_out#"${basedir}/"}"

	sed "${sed_args[@]}" -- "${f_in}" >"${f_out}" || die
}


_RINDEAL_UTILS_ECLASS=1
fi
