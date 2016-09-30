# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit rpm-r1

DESCRIPTION="Nonfree Ralink firmware files for the Linux kernel"
HOMEPAGE="https://www.kernel.org/"
LICENSE="ralink-firmware ralink_a_mediatek_company_firmware"

mageia_release="6"
MY_PV="${PV/_p/-}"
SLOT="0"
SRC_URI="mirror://mageia/distrib/${mageia_release}/x86_64/media/nonfree/release/${PN}-firmware-${MY_PV}.mga${mageia_release}.nonfree.noarch.rpm"
KEYWORDS="amd64 arm"

S="${WORKDIR}"

src_unpack() {
	local a
	for a in ${A} ; do
		case ${a} in
		*.rpm)
			rpm_unpack "${DISTDIR}/${a}" "${PWD}" "*/usr/share/*"
			;;
		*)		unpack "${a}" ;;
		esac
	done
}

src_install() {
	insinto /lib/firmware
	doins -r lib/firmware/*
}
