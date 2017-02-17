# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# functions: doicon, make_desktop_entry
inherit eutils
inherit xdg

DESCRIPTION="Interior design application to draw house plans and arrange furniture"
HOMEPAGE="http://www.sweethome3d.com/ https://sourceforge.net/projects/sweethome3d/"
LICENSE="GPL-2+"

SLOT="0"
PN_NB="${PN%"-bin"}"
P_NB="${PN_NB}-${PV}"
SRC_URI="https://sourceforge.net/projects/${PN_NB,,}/files/${PN_NB}/${P_NB}/${P_NB}.jar"

KEYWORDS="~amd64"
IUSE_A=( )

CDEPEND_A=( "virtual/jre:1.8" )
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

S="${WORKDIR}"

INST_DIR="/opt/${P}"

src_prepare() {
	default

	erm -r linux/ macosx/ windows/
}

src_configure() {
	:
}

src_compile() {
	jar cMf ${PN_NB,,}.jar * || die
}

src_install() {
	insinto "${INST_DIR}"
	doins "${PN_NB,,}.jar"

	## launcher
	cat <<-_EOF_ > "${PN_NB}.sh" || die
	#!/bin/sh
	java -jar "${EPREFIX}/${INST_DIR}/${PN_NB,,}.jar" "\${@}"
	_EOF_

	exeinto "${INST_DIR}/bin"
	doexe "${PN_NB}.sh"

	dosym "${INST_DIR}/bin/${PN_NB}.sh" "/usr/bin/${PN_NB,,}"

	doicon -s 128 "${FILESDIR}/${PN_NB}.png"

	## .desktop file
	local make_desktop_entry_args=(
		"${EPREFIX}/usr/bin/${PN_NB,,} %f"	# exec
		"${PN_NB}"	# name
		"${PN_NB}"	# icon
		'Graphics;3DGraphics;Java' # categories
	)
	local make_desktop_entry_extras=(
		'MimeType=application/x-sweethome3d;application/x-sh3-design;application/x-sh3-library;application/x-sh3-plugin;'
	)
	make_desktop_entry "${make_desktop_entry_args[@]}" \
		"$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"

	## mimetype associations
	insinto /usr/share/mime/packages
	doins "${FILESDIR}/${PN_NB,,}.xml"
}
