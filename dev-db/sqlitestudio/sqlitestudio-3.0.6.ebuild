# Copyright (C) 2015; Jan Chren <dev.rindeal@outlook.com>
# Distributed under the terms of the GNU General Public License v2

# Upstream guide: http://wiki.sqlitestudio.pl/index.php/Compiling_application_from_sources

EAPI=5

inherit qmake-utils fdo-mime versionator

PV_MAJ="$( get_major_version "$PV" )"
PN_PRETTY="SQLiteStudio${PV_MAJ}"

DESCRIPTION="${PN_PRETTY} is a powerful cross-platform SQLite database manager"
HOMEPAGE="http://${PN}.pl"
LICENSE="GPL-3"
SRC_URI="${HOMEPAGE}/files/${PN}${PV_MAJ}/complete/tar/${P}.tar.gz"

SLOT="0"
KEYWORDS="amd64 ~x86"

IUSE="
	cli
	tcl
	cups
	test
"

min_qt_ver=5.3

DEPEND="
	>=sys-devel/gcc-4.8

	>=dev-qt/designer-${min_qt_ver}
	cups? ( >=dev-qt/qtprintsupport-${min_qt_ver} )

	dev-db/sqlite:3

	cli? ( sys-libs/readline )
	tcl? ( dev-lang/tcl )
"

qtmodules="core gui widgets script network xml svg"
use test && qtmodules+=" test"

for m in $qtmodules; do
	DEPEND+=" >=dev-qt/qt${m}-${min_qt_ver}"
done

RDEPEND="${DEPEND}"

S="$WORKDIR"
core_build_dir="${S}/output/build"
core_src_dir="${S}/${PN_PRETTY}"
plugins_build_dir="${core_build_dir}/Plugins"
plugins_src_dir="${S}/Plugins"

disable_modules (){
	local file="$1"
	shift
	if [ $# -gt 0 ]; then
		edos2unix "$file"

		local regex=""
		for m in "$@"; do
			regex+="\b${m}\b( \\\\|\$)|"
		done
		regex="${regex:0:-1}" # last pipe

		elog "Disabling modules: '$*' in '${file}'"
		sed -i -r "/${regex}/d" "$file"
	fi
}

src_prepare () {
	epatch "${FILESDIR}/${PN}-3.0.6-qt5_5-QDataStream.patch"
	epatch "${FILESDIR}/${PN}-3.0.6-portable.patch"

	## Core
	disabled_modules=()

	use cli || disabled_modules+=( "cli" )

	disable_modules "${core_src_dir}/${PN_PRETTY}.pro" "${disabled_modules[@]}"

	## Plugins
	disabled_plugins=( 'DbSqlite2' )

	use tcl		|| disabled_plugins+=( "ScriptingTcl" )
	use cups	|| disabled_plugins+=( "Printing" )

	disable_modules "${plugins_src_dir}/Plugins.pro" "${disabled_plugins[@]}"
}

src_compile () {
	## Core

	mkdir -p "$core_build_dir" && cd "$core_build_dir"

	local qmake_args=(
		"LIBDIR=${EPREFIX}/usr/$(get_libdir)"
		"BINDIR=${EPREFIX}/usr/bin"

		"DEFINES+=PLUGINS_DIR=${EPREFIX}/usr/$(get_libdir)/${PN}"
		"DEFINES+=ICONS_DIR=${EPREFIX}/usr/share/${PN}/icons"
		"DEFINES+=FORMS_DIR=${EPREFIX}/usr/share/${PN}/forms"

		# not strictly needed since 3.0.6, but nevermind
		"DEFINES+=NO_AUTO_UPDATES"
	)
	use test && qmake_args+=( "DEFINES+=tests" )

	eqmake5 "${qmake_args[@]}" "$core_src_dir"
	emake

	## Plugins

	mkdir -p "$plugins_build_dir" && cd "$plugins_build_dir"

	eqmake5 "${qmake_args[@]}" "$plugins_src_dir"
	emake
}

src_install () {
	cd "$core_build_dir"	&& emake INSTALL_ROOT="$D" install
	cd "$plugins_build_dir" && emake INSTALL_ROOT="$D" install

	dodoc "${core_src_dir}/docs/${PN}${PV_MAJ}_docs.cfg"
	doicon "${FILESDIR}/${PN}.svg"

	make_desktop_entry_args=(
		"${EPREFIX}/usr/bin/${PN} %F"	# exec
		"${PN_PRETTY}"					# name
		"${PN}"							# icon
		"Development;Utility"			# categories
	)
	make_desktop_entry_extras=(
		'Terminal=false'
		"MimeType=application/x-sqlite3;"
	)
	make_desktop_entry "${make_desktop_entry_args[@]}" "$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"
}

pkg_postinst() {
	fdo-mime_desktop_database_update
}
