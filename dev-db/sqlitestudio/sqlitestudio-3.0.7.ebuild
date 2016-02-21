# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# Upstream guide: http://wiki.sqlitestudio.pl/index.php/Compiling_application_from_sources

EAPI=6

inherit qmake-utils fdo-mime

DESCRIPTION="SQLiteStudio3 is a powerful cross-platform SQLite database manager"
HOMEPAGE="http://sqlitestudio.pl"
LICENSE="GPL-3"
SRC_URI="${HOMEPAGE}/files/sqlitestudio3/complete/tar/${P}.tar.gz"

RESTRICT="mirror"
SLOT="0"
KEYWORDS="amd64"

IUSE="cli cups tcl test"

qt_min=5.3

RDEPEND=(
    '>=dev-qt/'{qt{core,gui,network,script,svg,widgets,xml},designer}-${qt_min}:5
    'dev-db/sqlite:3'
)
RDEPEND="${RDEPEND[@]}
	cups? ( >=dev-qt/qtprintsupport-${qt_min}:5 )
	cli? ( sys-libs/readline:= )
	tcl? ( dev-lang/tcl:= )
"
DEPEND="${RDEPEND}
	>=sys-devel/gcc-4.8:*
	test? ( >=dev-qt/qttest-${qt_min}:5 )
"

S="$WORKDIR"
core_build_dir="${S}/output/build"
core_src_dir="${S}/SQLiteStudio3"
plugins_build_dir="${core_build_dir}/Plugins"
plugins_src_dir="${S}/Plugins"

disable_modules() {
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
		sed -i -r "/${regex}/d" "$file" || return 1
	fi
}

PATCHES=( "${FILESDIR}/${PN}-"{3.0.6-qt5_5-QDataStream,3.0.6-portable,3.0.7-paths}'.patch' )

src_prepare() {
    default

	## Core
	local disabled_modules=()

	use cli	|| disabled_modules+=( 'cli' )

	disable_modules "${core_src_dir}/SQLiteStudio3.pro" "${disabled_modules[@]}" || die

	## Plugins
	local disabled_plugins=( 'DbSqlite2' )

	use tcl		|| disabled_plugins+=( 'ScriptingTcl' )
	use cups	|| disabled_plugins+=( 'Printing' )

	disable_modules "${plugins_src_dir}/Plugins.pro" "${disabled_plugins[@]}" || die
}

src_configure() {
	local qmake_args=(
		"LIBDIR=${ROOT}usr/$(get_libdir)"
		"BINDIR=${ROOT}usr/bin"
		"DEFINES+=PLUGINS_DIR=${ROOT}usr/$(get_libdir)/${PN}"
		"DEFINES+=ICONS_DIR=${ROOT}usr/share/${PN}/icons"
		"DEFINES+=FORMS_DIR=${ROOT}usr/share/${PN}/forms"

		# not strictly needed since 3.0.6, but nevermind
		'DEFINES+=NO_AUTO_UPDATES'
	)
	use test && qmake_args+=( 'DEFINES+=tests' )

	## Core
	mkdir -p "$core_build_dir" && cd "$core_build_dir" || die
	eqmake5 "${qmake_args[@]}" "$core_src_dir"

	## Plugins
	mkdir -p "$plugins_build_dir" && cd "$plugins_build_dir" || die
	eqmake5 "${qmake_args[@]}" "$plugins_src_dir"
}

src_compile() {
	## Core
	cd "$core_build_dir"	&& emake

	## Plugins
	cd "$plugins_build_dir"	&& emake
}

src_install() {
	cd "$core_build_dir"	&& emake INSTALL_ROOT="$D" install
	cd "$plugins_build_dir"	&& emake INSTALL_ROOT="$D" install

	dodoc "${core_src_dir}/docs/sqlitestudio3_docs.cfg"
	doicon -s scalable "${core_src_dir}/guiSQLiteStudio/img/${PN}.svg"

	make_desktop_entry_args=(
		"${ROOT}usr/bin/${PN} %F"	# exec
		'SQLiteStudio3'				# name
		"${PN}"						# icon
		'Development;Utility'		# categories
	)
	make_desktop_entry_extras=(
		'MimeType=application/x-sqlite3;'
	)
	make_desktop_entry "${make_desktop_entry_args[@]}" \
		"$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"
}

pkg_postinst() {
	fdo-mime_desktop_database_update
}
