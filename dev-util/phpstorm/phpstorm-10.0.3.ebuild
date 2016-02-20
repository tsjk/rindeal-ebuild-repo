# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils fdo-mime

SLOT="10"
MY_PN="${PN}${SLOT}"

DESCRIPTION="PhpStorm is a commercial, cross-platform IDE for PHP"
HOMEPAGE="https://www.jetbrains.com/phpstorm"
SRC_URI="https://download.jetbrains.com/webide/PhpStorm-${PV}.tar.gz"
LICENSE="PhpStorm PhpStorm_Academic PhpStorm_Classroom PhpStorm_OpenSource PhpStorm_personal"

KEYWORDS="~amd64 ~x86 ~arm"
RESTRICT="strip mirror"

RDEPEND="|| ( >=virtual/jdk-1.7 >=virtual/jre-1.6 )"

S="$WORKDIR"

# TODO: as soon as unpacker.eclass implements partial unpacks,
# we should exclude "<ROOT_DIR>/jre" dir here
# src_unpack() { }

src_prepare() {
	cd PhpStorm-*/
	S="$PWD"

	sed -i 's/IS_EAP="true"/IS_EAP="false"/' "bin/${PN}.sh"

	# use system JDK
	rm -rf jre/

	default
}

src_install() {
	local install_dir="/opt/${MY_PN}"

	insinto "$install_dir"
	doins -r .

	fperms a+x "${install_dir}/bin/"{${PN}.sh,fsnotifier{,64,-arm}}
	dosym "${install_dir}/bin/${PN}.sh" /usr/bin/${MY_PN}

	newicon -s 256 "bin/webide.png" "${MY_PN}.png"

	make_desktop_entry_args=(
		"${MY_PN} %U"						# exec
		"PhpStorm ${SLOT}"					# name
		"${MY_PN}"							# icon
		"Development"						# categories
	)
	make_desktop_entry_extras=(
		"MimeType=text/x-php;text/html;"	# MUST end with semicolon
	)

	make_desktop_entry "${make_desktop_entry_args[@]}" "$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"
}

pkg_postinst() {
	fdo-mime_desktop_database_update
}
