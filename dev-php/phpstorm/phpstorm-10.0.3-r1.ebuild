# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils fdo-mime

SLOT="10"
PN_SLOTTED="${PN}${SLOT}"

DESCRIPTION="PhpStorm is a commercial, cross-platform IDE for PHP"
HOMEPAGE="https://www.jetbrains.com/phpstorm"
LICENSE="PhpStorm PhpStorm_Academic PhpStorm_Classroom PhpStorm_OpenSource PhpStorm_personal"
SRC_URI="https://download.jetbrains.com/webide/PhpStorm-${PV}.tar.gz"

KEYWORDS="~amd64 ~x86 ~arm"
RESTRICT="strip mirror"
IUSE="system-jre"

RDEPEND="system-jre? ( || ( >=virtual/jdk-1.7 >=virtual/jre-1.6 ) )"

S="${WORKDIR}"

# TODO: as soon as unpacker.eclass implements partial unpacks,
# we should exclude "<ROOT_DIR>/jre" dir here
# src_unpack() { }

src_unpack() {
	default

	cd PhpStorm-*/
	S="$PWD"
}

src_prepare() {
	default

	sed -i 's/IS_EAP="true"/IS_EAP="false"/' "bin/${PN}.sh" || die

	use system-jre && rm -rf jre/
}

src_install() {
	local install_dir="/opt/${PN_SLOTTED}"

	insinto "${install_dir}"
	doins -r .
	fperms a+x "${install_dir}/bin/"{${PN}.sh,fsnotifier{,64,-arm}}
	use system-jre || chmod a+x "${D}/${install_dir}"/jre/jre/bin/*

	dosym "${install_dir}/bin/${PN}.sh" "/usr/bin/${PN_SLOTTED}"

	newicon -s 256 "bin/webide.png" "${PN_SLOTTED}.png"

	make_desktop_entry_args=(
		"${PN_SLOTTED} %U"					# exec
		"PhpStorm ${SLOT}"					# name
		"${PN_SLOTTED}"						# icon
		"Development;IDE;WebDevelopment"	# categories
	)
	make_desktop_entry_extras=( # MUST end with semicolon
		"MimeType=text/x-php;text/html;"
	)
	make_desktop_entry "${make_desktop_entry_args[@]}" "$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"
}

pkg_postinst() {
	fdo-mime_desktop_database_update
}
