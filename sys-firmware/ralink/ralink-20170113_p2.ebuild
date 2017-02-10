# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

inherit rpm

DESCRIPTION="Nonfree Ralink firmware files for the Linux kernel"
HOMEPAGE="https://www.kernel.org/"
LICENSE="ralink-firmware ralink_a_mediatek_company_firmware"

SLOT="0"
mageia_release="6"
MY_PV="${PV/_p/-}"
SRC_URI="mirror://mageia/distrib/${mageia_release}/x86_64/media/nonfree/release/${PN}-firmware-${MY_PV}.mga${mageia_release}.nonfree.noarch.rpm"

KEYWORDS="amd64"

S="${WORKDIR}"

CDEPEND_A=( )
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	"!>=sys-kernel/linux-firmware-20170101"
)

src_install() {
	insinto /lib/firmware
	doins -r lib/firmware/*
}
