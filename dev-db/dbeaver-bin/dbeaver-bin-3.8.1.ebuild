# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils xdg

PN_NOBIN="${PN%-bin}"

DESCRIPTION="Free universal database manager and SQL client"
HOMEPAGE="http://dbeaver.jkiss.org/"
LICENSE="GPL-2"

SLOT="0"
src_uri_base="https://github.com/serge-rider/dbeaver/releases/download/${PV}/dbeaver-ce-${PV}-linux.gtk"
SRC_URI="
	amd64? ( ${src_uri_base}.x86_64.tar.gz )"
RESTRICT="mirror strip test"

KEYWORDS="-* ~amd64"

RDEPEND="
	|| ( >=virtual/jdk-1.7 >=virtual/jre-1.7 )
	!dev-db/dbeaver"

S="${WORKDIR}/${PN_NOBIN}"

src_compile() { : ;}

src_install (){
	local install_dir="/opt/${PN_NOBIN}"
	local bin="/usr/bin/${PN_NOBIN}"

	insinto "${install_dir}"
	doins -r *

	fperms a+x "${install_dir}/${PN_NOBIN}"
	dosym "${install_dir}/${PN_NOBIN}" "${bin}"

	newicon -s 256 "icon.xpm" "${PN_NOBIN}.xpm"

	local make_desktop_entry_args=(
		"${EPREFIX}${bin} %U" # exec
		"DBeaver"	# name
		"${PN_NOBIN}"	# icon
		"Development;Database"	# categories
	)
	local make_desktop_entry_extras=(
		"MimeType=application/x-sqlite3;"	# MUST end with semicolon
	)
	make_desktop_entry \
		"${make_desktop_entry_args[@]}" \
		"$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"
}
