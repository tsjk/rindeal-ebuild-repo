# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

DESCRIPTION="Breeze dark icons set for Libreoffice"
HOMEPAGE="https://github.com/NitruxSA/plasma-next-icons"
LICENSE="LGPL"
SRC_URI="https://github.com/aitorpazos/archlinux-libreoffice-breeze-icons/releases/download/${PV}/libreoffice-breeze-icons-${PV}.tar.gz"
RESTRICT="mirror"

SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_install() {
	insinto '/usr/lib/libreoffice/share/config'
	doins 'images_breeze_dark.zip'
}
