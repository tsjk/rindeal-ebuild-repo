# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: github.eclass
# @MAINTAINER:
# Jan Chren (rindeal) <dev.rindeal+gentoo-overlay@gmail.com>
# @BLURB: Support eclass for packages hosted on Github
# @DESCRIPTION:
# Support eclass for packages hosted on Github
# Based on https://github.com/mrueg/mrueg-overlay/blob/master/eclass/github.eclass

if [ -z "${_GH_ECLASS}" ] ;then

case "${EAPI:-0}" in
	5|6)
		;;
	*)
		die "Unsupported EAPI=${EAPI} (unknown) for ${ECLASS}"
		;;
esac

inherit versionator

# @ECLASS-VARIABLE: GH_REPO
# @DESCRIPTION:
# Github repository name
: ${GH_REPO:=${PN}}

# @ECLASS-VARIABLE: GH_USER
# @DESCRIPTION:
# Github username/group name
: ${GH_USER:=${PN}}

# @ECLASS-VARIABLE: GH_TAG
# @DESCRIPTION:
# Tag/commit that is fetched from Github
: ${GH_TAG:=v${PV}}

# @ECLASS-VARIABLE: GH_BUILD_TYPE
# @DEFAULT_UNSET
# @DESCRIPTION:
# Defines if fetched from git ("live") or tarball ("release")
if [ -z "${GH_BUILD_TYPE}" ] ;then
	if version_is_at_least 9999 ;then
		GH_BUILD_TYPE='live'
	else
		GH_BUILD_TYPE='release'
	fi
fi


case "${GH_BUILD_TYPE}" in
	'release')
		inherit vcs-snapshot

		SRC_URI="https://github.com/${GH_USER}/${GH_REPO}/archive/${GH_TAG}.tar.gz -> ${P}.tar.gz"
		;;
	'live')
		inherit git-r3

		EGIT_REPO_URI="https://github.com/${GH_USER}/${GH_REPO}.git"
		;;
	*)
		die "Invalid GH_BUILD_TYPE: '${GH_BUILD_TYPE}'"
		;;
esac


HOMEPAGE="https://github.com/${GH_USER}/${GH_REPO}"

RESTRICT+=' primaryuri'


# @FUNCTION: github_src_unpack
# @DESCRIPTION:
# Function for unpacking Github packages
github_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	if [ ${GH_BUILD_TYPE} = 'live' ] ;then
		git-r3_src_unpack
	else
		vcs-snapshot_src_unpack
	fi
}

_GH_ECLASS=1
fi
