# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# functions: newicon, make_desktop_entry
inherit eutils
inherit xdg
# functions: get_major_version
inherit versionator

DESCRIPTION="Free universal database manager and SQL client"
HOMEPAGE="http://dbeaver.jkiss.org/ https://github.com/serge-rider/dbeaver"
LICENSE="Apache-2.0"

PN_NB="${PN%-bin}"

DBEAVER_SLOT="$(get_major_version)"
SLOT="${DBEAVER_SLOT}"
src_uri_base="https://github.com/serge-rider/${PN_NB}/releases/download/${PV}/${PN_NB}-ce-${PV}-linux.gtk"
SRC_URI_A=(
	"amd64? ( ${src_uri_base}.x86_64.tar.gz )"
)

KEYWORDS="-* ~amd64"

RDEPEND_A=(
	">=virtual/jre-1.8"
	"!dev-db/dbeaver"
)

RESTRICT="mirror strip test"

inherit arrays

S="${WORKDIR}/${PN_NB}"

src_compile() { : ;}

src_install (){
	local install_dir="/opt/${PN_NB}${DBEAVER_SLOT}"
	local bin="/usr/bin/${PN_NB}${DBEAVER_SLOT}"

	insinto "${install_dir}"
	doins -r *

	fperms a+x "${install_dir}/${PN_NB}"
	dosym "${install_dir}/${PN_NB}" "${bin}"

	newicon -s 128 "${PN_NB}.png" "${bin##*/}.png"

	local make_desktop_entry_args=(
		"${EPREFIX}${bin} %U" # exec
		"DBeaver ${DBEAVER_SLOT}"	# name
		"${bin##*/}"	# icon
		"Development;Database;IDE;"	# categories
	)
	local make_desktop_entry_extras=(
		"MimeType=application/x-sqlite3;"	# MUST end with semicolon
		"StartupWMClass=DBeaver"
		"StartupNotify=true"
		"GenericName=SQL Database Client"
	)
	make_desktop_entry \
		"${make_desktop_entry_args[@]}" \
		"$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"
}
