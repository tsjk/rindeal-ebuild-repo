# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# wxwidgets.eclass
WX_GTK_VER="3.0"
# git-hosting.eclass
GH_URI='github/eranif'

inherit git-hosting
# functions: setup-wxwidgets
inherit wxwidgets
# EXPORT_FUNCTIONS: src_prepare, src_configure, src_compile, src_test, src_install
inherit cmake-utils
# EXPORT_FUNCTIONS: src_prepare, pkg_preinst, pkg_postinst, pkg_postrm
inherit xdg

DESCRIPTION="Free, open source, cross platform C,C++,PHP and Node.js IDE"
HOMEPAGE="http://www.codelite.org ${GH_HOMEPAGE}"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64"
IUSE_A=( +clang flex lldb mysql pch +sftp webview +wxAuiNotebook wxCrafter )

CDEPEND_A=(
	"dev-db/sqlite:3"
	"x11-libs/wxGTK:3.0"
	"clang? ( sys-devel/clang:0 )"
	"flex? ( sys-devel/flex )"
	"lldb? ( || ("
		"<sys-devel/llvm-3.9[lldb]"
		"dev-util/lldb"
	") )"
	"mysql? ( virtual/mysql )"
	"sftp? ( net-libs/libssh )"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

CHECKREQS_DISK_BUILD='2G'
inherit check-reqs

L10N_LOCALES=( cs zh_CN )
inherit l10n-r1

src_prepare-locales() {
	local l locales dir="translations" pre="" post="/LC_MESSAGES/codelite.mo"

	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"

	l10n_get_locales locales app off
	for l in ${locales} ; do
		erm -r "${dir}/${l}"
	done
}

pkg_setup() {
	setup-wxwidgets
}

src_prepare() {
	eapply "${FILESDIR}/codelite_dont_strip.patch"
	eapply_user

	src_prepare-locales

	xdg_src_prepare
	cmake-utils_src_prepare

	# respect CXXFLAGS
	sed -e '/CXX_FLAGS/ s|-O2||' -i -- CMakeLists.txt || die
}

src_configure() {
	local mycmakeargs=(
		-DENABLE_CLANG=$(usex clang 1 0)
		-DENABLE_SFTP=$(usex sftp 1 0)
		-DENABLE_LLDB=$(usex lldb 1 0)

		-DWITH_FLEX=$(usex flex 1 0)
		-DWITH_MYSQL=$(usex mysql 1 0)
		-DWITH_PCH=$(usex pch 1 0)
		-DWITH_WEBVIEW=$(usex webview 1 0)
		-DWITH_WXC=$(usex wxCrafter 1 0)

		-DGTK_USE_NATIVEBOOK=$(usex !wxAuiNotebook 1 0)
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	erm "${ED}"/usr/share/applications/${PN}.desktop
	local make_desktop_entry_args=(
		"${EPREFIX}/usr/bin/${PN} %f"    # exec
		"CodeLite"	# name
		"${PN}"		# icon
		'Development;IDE;' # categories; https://standards.freedesktop.org/menu-spec/latest/apa.html
	)
	local make_desktop_entry_extras=(
# 		'MimeType=;' # TODO
		"StartupNotify=true"
	)
	make_desktop_entry "${make_desktop_entry_args[@]}" \
		"$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"
}
