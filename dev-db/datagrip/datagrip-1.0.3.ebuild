# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils fdo-mime

SLOT="1"
PN_SLOTTED="${PN}${SLOT}"

DESCRIPTION="DataGrip is a commercial multi-engine database environment"
HOMEPAGE="https://www.jetbrains.com/datagrip"
LICENSE="IDEA || ( IDEA_Academic IDEA_Classroom IDEA_OpenSource IDEA_Personal )"
SRC_URI="http://download.jetbrains.com/datagrip/${P}-custom-jdk-linux.tar.gz"

KEYWORDS="~amd64 ~x86"
RESTRICT="strip mirror"
IUSE="system-jre"

RDEPEND="system-jre? ( || ( >=virtual/jdk-1.7 >=virtual/jre-1.6 ) )"

S="${WORKDIR}/DataGrip-${PV}"

src_prepare() {
	default

	if use system-jre	; then rm -rvf jre || die ; fi
}

src_install() {
	local install_dir="/opt/${PN_SLOTTED}"

	insinto "${install_dir}"
	doins -r .
	fperms a+x "${install_dir}/bin/"{${PN}.sh,fsnotifier{,64,-arm}}
	use system-jre || chmod a+x "${D}/${install_dir}"/jre/jre/bin/*

	dosym "${install_dir}/bin/${PN}.sh" "/usr/bin/${PN_SLOTTED}"

	newicon -s 128 "bin/product.png" "${PN_SLOTTED}.png"

	make_desktop_entry_args=(
		"${PN_SLOTTED} %U"			# exec
		"DataGrip ${SLOT}"			# name
		"${PN_SLOTTED}"				# icon
		"Development;IDE;Database"	# categories
	)
	make_desktop_entry_extras=( # MUST end with semicolon
	)
	make_desktop_entry "${make_desktop_entry_args[@]}" "$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"
}

pkg_postinst() {
	fdo-mime_desktop_database_update
}
