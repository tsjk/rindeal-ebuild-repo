# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: eclass-patches.eclass
# @MAINTAINER:
# Jan Chren (rindeal) <dev.rindeal+gentoo-overlay@gmail.com>
# @BLURB: Collection of overrides of functions from eclasses from the tree
# @DESCRIPTION:

case "${EAPI:-0}" in
    5|6) ;;
    *) die "Unsupported EAPI='${EAPI}' for '${ECLASS}'" ;;
esac

# ORIGIN: flag-o-matic
# PR: https://github.com/gentoo/gentoo/pull/1425
get-flag() {
	local var findflag="${1}"

	# this code looks a little flaky but seems to work for
	# everything we want ...
	# for example, if CFLAGS="-march=i686":
	# `get-flag -march` == "-march=i686"
	# `get-flag march` == "i686"
	for var in $(all-flag-vars) ; do
		# reverse loop
		set -- ${!var}
		local i=$#
		while [ $i -gt 0 ] ; do
			local f="${!i}"
			if [ "${f#-${findflag#-}}" != "${f}" ] ; then
				printf "%s\n" "${f#-${findflag}=}"
				return 0
			fi
			((i--))
		done
	done
	return 1
}
