# Copyright (C) 2015; Jan Chren <dev.rindeal@outlook.com>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils fdo-mime

PN_PRETTY="DBeaver"
PN_BASE="dbeaver"
DESCRIPTION="Free universal database manager and SQL client"
HOMEPAGE="http://dbeaver.jkiss.org/"
LICENSE="GPL-2"
SRC_URI="https://github.com/serge-rider/${PN_BASE}/releases/download/${PV}/${PN_BASE}-ce-${PV}-linux.gtk.x86_64.tar.gz"

RESTRICT="mirror strip"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="|| ( >=virtual/jdk-1.7 >=virtual/jre-1.7 )"

S="$WORKDIR/$PN_BASE"

src_install (){
	local install_dir="/opt/${PN_PRETTY}"
	local bin="/usr/bin/${PN_BASE}"

	insinto "$install_dir"
	doins -r .

	fperms a+x "${install_dir}/${PN_BASE}"
	dosym "${install_dir}/${PN_BASE}" "$bin"

	newicon -s 256 "icon.xpm" "${PN_BASE}.xpm"

	make_desktop_entry_args=(
		"${bin} %U"							# exec
		"$PN_PRETTY"						# name
		"$PN_BASE"							# icon
		"Development"						# categories
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
