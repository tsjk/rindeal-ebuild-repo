# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

GH_USER='jpmens'
GH_TAG="v${PV}"

inherit github autotools

DESCRIPTION='Web log analyzer using probabilistic data structures'
LICENSE='GPL-2'

SLOT='0'

KEYWORDS='~amd64 ~arm ~x86'

src_prepare() {
	default

	eautoreconf
}
