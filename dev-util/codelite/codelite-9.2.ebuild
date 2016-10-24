# Copyright 1999-2015 Gentoo Foundation; 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

WX_GTK_VER="3.0"

GH_URI='github/eranif'

inherit cmake-utils wxwidgets git-hosting

DESCRIPTION="A Free, open source, cross platform C,C++,PHP and Node.js IDE"
HOMEPAGE="http://www.codelite.org"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~x86"
IUSE="+clang flex lldb mysql pch +sftp webview +wxAuiNotebook wxCrafter"

DEPEND="
	dev-db/sqlite:3
	x11-libs/wxGTK:3.0
	clang? ( sys-devel/clang )
	flex? ( sys-devel/flex )
	lldb? ( sys-devel/llvm[lldb] )
	mysql? ( virtual/mysql )
	sftp? ( net-libs/libssh )
"

RDEPEND="${DEPEND}"

CHECKREQS_DISK_BUILD='2G'
inherit check-reqs

src_prepare() {
	PATCHES=( "${FILESDIR}/codelite_dont_strip.patch" )
	default

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
