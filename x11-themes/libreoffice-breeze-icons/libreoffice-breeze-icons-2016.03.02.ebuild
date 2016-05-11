# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

DESCRIPTION="Breeze dark icons set for Libreoffice"
HOMEPAGE="https://github.com/NitruxSA/plasma-next-icons"
LICENSE="LGPL-3"

SLOT="0"
SRC_URI="https://github.com/aitorpazos/archlinux-libreoffice-breeze-icons/releases/download/${PV}/${P}.tar.gz"

KEYWORDS="~amd64 ~arm ~arm64 ~x86"

S="${WORKDIR}"

src_install() {
	insinto '/usr/lib/libreoffice/share/config'
	doins 'images_breeze_dark.zip'
}

pkg_postinst() {
	elog "To enable this theme in LibreOffice, go to Tools->Options->View menu and select it there"
}
