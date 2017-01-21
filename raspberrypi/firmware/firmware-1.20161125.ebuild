# Copyright 1999-2016 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_URI="github/raspberrypi/firmware"

inherit git-hosting

DESCRIPTION="Raspberry PI boot loader and firmware"
LICENSE="GPL-2 raspberrypi-videocore-bin"

SLOT="0"

KEYWORDS="-* ~arm ~arm64"

RDEPEND="!sys-boot/raspberrypi-firmware"

RESTRICT="binchecks strip"

: "${RPI_FW_INSTALL_DIR:="${ROOT}boot"}"

pkg_preinst() {
	if ! grep -q "${RPI_FW_INSTALL_DIR}" /proc/mounts ; then
		ewarn "'${RPI_FW_INSTALL_DIR}' is not mounted, the files might not be installed at the right place"
	fi
}

src_configure() { :; }

src_compile() { :; }

src_install() {
	cd boot || die

	local inst_dir="${D}/${RPI_FW_INSTALL_DIR}/"
	mkdir -v -p "${inst_dir}" || die

	local files=(
		bootcode.bin
		start*.elf
		fixup*.dat
		*.dtb
	)
	cp -v "${files[@]}" "${inst_dir}" || die
	cp -vr overlays/ "${inst_dir}" || die

	echo "${GH_REF}" > "${inst_dir}/firmware-version" || die
}
