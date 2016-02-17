# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

DESCRIPTION="Rindeal's Function Library for OpenRC"
HOMEPAGE="https://github.com/rindeal/openrc-rfl"
LICENSE="BSD-3"
SRC_URI="https://github.com/rindeal/openrc-rfl/archive/v${PV}.tar.gz -> ${P}.tar.gz"

RESTRICT="mirror"
SLOT="0"
KEYWORDS="~amd64 ~arm"

RDEPEND="sys-apps/openrc"

src_prepare()
{
	default

	export RFL_ROOT_DIR="$( echo "${ROOT}/usr/share/${PN}" | tr -s '/' )"
}
