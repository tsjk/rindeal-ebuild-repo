# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:LongSoft:UEFITool"

inherit git-hosting
# functions: eqmake5
inherit qmake-utils
inherit xdg

DESCRIPTION="C++/Qt program for parsing, extracting and modifying UEFI firmware images"
LICENSE="BSD-2"

SLOT="0"

KEYWORDS=""
IUSE="qt5"

CDEPEND_A=(
	"qt5? ("
		"dev-qt/qtcore:5"
		"dev-qt/qtgui:5"
		"dev-qt/qtwidgets:5"
	")"
	"!qt5? ("
		"dev-qt/qtcore:4"
		"dev-qt/qtgui:4"
	")"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

my_eqmake() {
	eqmake$(usex qt5 5 4) "$@"
}

for_each_extra_tool() {
	local MY_EXTRA_TOOLS=( UEFIExtract UEFIFind UEFIPatch )
	for x in "${MY_EXTRA_TOOLS[@]}" ; do
		epushd "${x}"
		"$@" "${x}"
		epopd
	done
}

src_configure() {
	my_eqmake "${PN}.pro"

	my_config_extra_tool() { my_eqmake "${1,,}.pro"; }
	for_each_extra_tool my_config_extra_tool
}

src_compile() {
	emake

	my_compile_extra_tool() { emake; }
	for_each_extra_tool my_compile_extra_tool
}

src_install() {
	dobin UEFITool

	my_install_extra_tool() { dobin "$1"; }
	for_each_extra_tool my_install_extra_tool

	einstalldocs

	local make_desktop_entry_args=(
		"${EPREFIX}/usr/bin/UEFITool -- %f"	# exec
		"UEFITool"	# name
		"utilities-terminal"	# icon
		'System;Utility;FileTools'	# categories
	)
	local make_desktop_entry_extras=(
# 		'MimeType=;'
	)
	make_desktop_entry "${make_desktop_entry_args[@]}" \
		"$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"
}
