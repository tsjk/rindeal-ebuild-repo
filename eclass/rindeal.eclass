# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: rindeal.eclass
# @MAINTAINER:
# Jan Chren (rindeal) <dev.rindeal+gentoo-overlay@gmail.com>
# @BLURB: Collection of handy functions for my overlay
# @DESCRIPTION:

if [ -z "${_RINDEAL_ECLASS}" ] ; then

case "${EAPI:-0}" in
    5|6) ;;
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

	# unquoted $* ensures, whitespaces won't get through
	for c in ${cond[*]} ; do
		ret+="${c}? ( $* )"$'\n'
	done

	echo "${ret}"
}

_RINDEAL_ECLASS=1
fi
