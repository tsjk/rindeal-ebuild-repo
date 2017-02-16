# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# functions: newicon, make_desktop_entry
inherit eutils
inherit xdg

DESCRIPTION="Interior design application to draw house plans and arrange furniture"
HOMEPAGE="http://www.sweethome3d.com/ https://sourceforge.net/projects/sweethome3d/"
LICENSE="GPL-2+"

SLOT="0"
PN_NB="${PN%"-bin"}"
P_NB="${PN_NB}-${PV}"
SRC_URI="amd64? ( https://sourceforge.net/projects/${PN_NB,,}/files/${PN_NB}/${P_NB}/${P_NB}-linux-x64.tgz )"

KEYWORDS="-* ~amd64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=( )
RESTRICT+=""

inherit arrays

S="${WORKDIR}/${P_NB}"

INST_DIR="/opt/${P}"

src_prepare() {
	default

	sed  \
		-e "s@\"\$PROGRAM_DIR\"/jre8/bin/java@\"${EPREFIX}\"/usr/bin/java@g" \
		-e "s@\"\$PROGRAM_DIR\"/jre8/lib@\"\$(java-config-2 -o)\"/lib@g" \
		-e "s@\"\$PROGRAM_DIR\"/lib@\"${EPREFIX}${INST_DIR}\"/lib@g" \
		-i -- "${PN_NB}" || die
}

src_configure() {
	:
}

src_compile() {
	:
}

src_install() {
	insinto "${INST_DIR}"
	doins -r "lib/"

	## launcher
	exeinto "${INST_DIR}/bin"
	doexe "${PN_NB}"
	dosym "${INST_DIR}/bin/${PN_NB}" "/usr/bin/${PN_NB,,}"

	newicon -s 128 "${PN_NB}Icon.png" "${PN_NB}.png"

	## .desktop file
	local make_desktop_entry_args=(
		"${EPREFIX}/usr/bin/${PN_NB,,} %f"	# exec
		"${PN_NB}"	# name
		"${PN_NB}"	# icon
		'Graphics;2DGraphics;3DGraphics;Java' # categories
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

QA_PRESTRIPPED="${INST_DIR}/lib/java3d-1.6/.*\.so"
