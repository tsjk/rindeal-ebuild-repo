# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

DESCRIPTION="Rindeal's Function Library for OpenRC"
HOMEPAGE="https://github.com/rindeal/openrc-rfl"
LICENSE="BSD"
SRC_URI="https://github.com/rindeal/openrc-rfl/archive/v${PV}.tar.gz -> ${P}.tar.gz"

RESTRICT='mirror binchecks'
SLOT="0"
KEYWORDS="~amd64 ~arm"

RDEPEND="sys-apps/openrc"

src_prepare()
{
	default

	RFL_ROOT_DIR="${ROOT}/usr/share/${PN}"
	RFL_ROOT_DIR="${RFL_ROOT_DIR//\/\///}"
	export RFL_ROOT_DIR
}
