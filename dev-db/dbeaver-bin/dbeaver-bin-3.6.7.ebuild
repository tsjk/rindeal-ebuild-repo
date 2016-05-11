# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils fdo-mime

MY_PN="${PN%-bin}"

DESCRIPTION="Free universal database manager and SQL client"
HOMEPAGE="http://dbeaver.jkiss.org/"
LICENSE="GPL-2"

SLOT="0"
src_uri_base="https://github.com/serge-rider/dbeaver/releases/download/${PV}/dbeaver-ce-${PV}-linux.gtk"
SRC_URI="
	amd64? ( ${src_uri_base}.x86_64.tar.gz )
	x86? ( ${src_uri_base}.x86.tar.gz )"
RESTRICT="mirror strip test"

KEYWORDS="-* ~amd64 ~x86"

RDEPEND="
	|| ( >=virtual/jdk-1.7 >=virtual/jre-1.7 )
	!dev-db/dbeaver
"

S="${WORKDIR}/${MY_PN}"

src_compile() { : ;}

src_install (){
	local install_dir="${EPREFIX}/opt/${MY_PN}"
	local bin="${EPREFIX}/usr/bin/${MY_PN}"

	insinto "${install_dir}"
	doins -r *

	fperms a+x "${install_dir}/${MY_PN}"
	dosym "${install_dir}/${MY_PN}" "${bin}"

	newicon -s 256 "icon.xpm" "${MY_PN}.xpm"

	make_desktop_entry_args=(
		"${bin} %U"				# exec
		"DBeaver"				# name
		"${MY_PN}"				# icon
		"Development;Database"	# categories
	)
	make_desktop_entry_extras=(
		"MimeType=application/x-sqlite3;"	# MUST end with semicolon
	)
	make_desktop_entry \
		"${make_desktop_entry_args[@]}" \
		"$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"
}

pkg_postinst() {
	fdo-mime_desktop_database_update
}
