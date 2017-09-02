# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

inherit qmake-utils
inherit xdg
inherit eutils
inherit qt-pro-formatter

DESCRIPTION="Powerful cross-platform SQLite database manager"
HOMEPAGE="https://sqlitestudio.pl"
LICENSE="GPL-3"

SLOT="0"
SRC_URI="https://sqlitestudio.pl/files/sqlitestudio3/complete/tar/${P}.tar.gz"

KEYWORDS="~amd64"
IUSE="cli cups nls tcl test"

CDEPEND_A=(
	"dev-db/sqlite:3"

	dev-qt/qt{core,gui,network,script,svg,widgets,xml}:5

	"cups? ( dev-qt/qtprintsupport:5 )"
	"cli? ( sys-libs/readline:* )"
	"tcl? ( dev-lang/tcl:* )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-qt/designer:5"
	"test? ( dev-qt/qttest:5 )"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

# Upstream guide: http://wiki.sqlitestudio.pl/index.php/Compiling_application_from_sources

# this dir structure resembles upstream guide
S="${WORKDIR}"
MY_CORE_SRC_DIR="${S}/SQLiteStudio3"
MY_PLUGINS_SRC_DIR="${S}/Plugins"
MY_CORE_BUILD_DIR="${S}/output/build"
MY_PLUGINS_BUILD_DIR="${MY_CORE_BUILD_DIR}/Plugins"

pkg_setup() {
	# NOTE: SQLITESTUDIO_*_DIRS dirs can also be specified at runtime
	# NOTE: as `SQLITESTUDIO_{PLUGINS,ICONS,FORMS}` env vars, which
	# NOTE: also accept multiple values as `:` separated list.

	# Additional directory to look up for plugins.
	# NOTE: this dir is the same as for core plugins
	SQLITESTUDIO_PLUGINS_DIR="/usr/$(get_libdir)/${PN}"
	# Additional directory to look up for icons.
	SQLITESTUDIO_ICONS_DIR="/usr/share/${PN}/icons"
	# Additional directory to look up for *.ui files (forms used by plugins).
	SQLITESTUDIO_FORMS_DIR="/usr/share/${PN}/forms"
}

src_prepare() {
	xdg_src_prepare

	eshopts_push -s globstar
	local pro_files=( **/*.pro )
	format_qt_pro "${pro_files[@]}"
	eshopts_pop

	# fix wrong portable conditional
	# it should be: `portable { ... ; linux { ... } ; }`
	sed -e 's@linux|portable@portable@' \
		-i -- "${MY_CORE_SRC_DIR}"/sqlitestudio/sqlitestudio.pro || die

	if ! use nls ; then
		# delete all files with translations
		find -type f \( -name "*.ts" -o -name "*.qm" \) -delete || die
		# delete refs in project files
		find -type f -name "*.pro" -print0 | xargs -0 sed -e '/^TRANSLATIONS/d' -i --
		assert
		# delete refs in resource files
		find -type f -name "*.qrc" -print0 | xargs -0 sed -e '\|\.qm</file>|d' -i --
		assert
	fi

	disable_modules() {
		debug-print-function "${FUNCTION}" "${@}"
		local file="$1"; shift
		local modules=( "${@}" )

		# skip if no modules specified
		(( ${#modules[@]} )) || return 0

		# build regex simply looking like this: `module1(\|$)|module2(\|$)`
		local m regex=""
		for m in "${modules[@]}" ; do
			regex+="\b${m}\b[ \t]*(\\\\|\r?\$)|"
		done
		regex="${regex%"|"}"

		einfo "Disabling modules: '${modules[*]}' in '${file#${S}/}'"
		sed -r -e "/${regex}/d" -i -- "${file}" || die
	}

	## Core
	local disabled_modules=(
		$(usex cli '' 'cli')
	)
	disable_modules "${MY_CORE_SRC_DIR}/SQLiteStudio3.pro" "${disabled_modules[@]}"

	## Plugins
	local disabled_plugins=(
		'DbSqlite2'	# we provide no support for sqlite2
		$(usex tcl '' 'ScriptingTcl')
		$(usex cups '' 'Printing')
	)
	disable_modules "${MY_PLUGINS_SRC_DIR}/Plugins.pro" "${disabled_plugins[@]}"
}

src_configure() {
	local qmake_args=(
		"BINDIR=${EPREFIX}/usr/bin"
		"LIBDIR=${EPREFIX}/usr/$(get_libdir)"

		"DEFINES+=PLUGINS_DIR=\"${EPREFIX}${SQLITESTUDIO_PLUGINS_DIR}\""
		"DEFINES+=ICONS_DIR=\"${EPREFIX}${SQLITESTUDIO_ICONS_DIR}\""
		"DEFINES+=FORMS_DIR=\"${EPREFIX}${SQLITESTUDIO_FORMS_DIR}\""

		$(usex test 'DEFINES+=tests' '')
	)

	## Core
	mkdir -p "${MY_CORE_BUILD_DIR}" && cd "${MY_CORE_BUILD_DIR}" || die
	eqmake5 "${qmake_args[@]}" "${MY_CORE_SRC_DIR}"

	## Plugins
	mkdir -p "${MY_PLUGINS_BUILD_DIR}" && cd "${MY_PLUGINS_BUILD_DIR}" || die
	eqmake5 "${qmake_args[@]}" "${MY_PLUGINS_SRC_DIR}"
}

src_compile() {
	emake -C "${MY_CORE_BUILD_DIR}"
	emake -C "${MY_PLUGINS_BUILD_DIR}"
}

src_install() {
	emake -C "${MY_CORE_BUILD_DIR}"		INSTALL_ROOT="${D}" install
	emake -C "${MY_PLUGINS_BUILD_DIR}"	INSTALL_ROOT="${D}" install

	doicon -s scalable "${MY_CORE_SRC_DIR}/guiSQLiteStudio/img/${PN}.svg"

	## system-wide dirs for addons
	keepdir "${SQLITESTUDIO_PLUGINS_DIR}"
	keepdir "${SQLITESTUDIO_ICONS_DIR}"
	keepdir "${SQLITESTUDIO_FORMS_DIR}"

	make_desktop_entry_args=(
		"${EPREFIX}/usr/bin/${PN} -- %F"	# exec
		'SQLiteStudio3'	# name
		"${PN}"	# icon
		'Development;Database;Utility'	# categories
	)
	make_desktop_entry_extras=( 'MimeType=application/x-sqlite3;' )
	make_desktop_entry "${make_desktop_entry_args[@]}" \
		"$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"
}
