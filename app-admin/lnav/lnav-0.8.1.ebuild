# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GH_URI="github/tstack"
PYTHON_COMPAT=( python2_7 )

inherit git-hosting python-any-r1

DESCRIPTION="A curses-based tool for viewing and analyzing log files"
HOMEPAGE="http://lnav.org ${HOMEPAGE}"
LICENSE="BSD-2"

SLOT="0"
SRC_URI="https://github.com/tstack/lnav/releases/download/v${PV}/${P}.tar.gz"

KEYWORDS="~amd64 ~arm ~x86"
IUSE="pcre readline static test unicode"

# system-wide yajl cannot be used, because lnav uses custom-patched version
RDEPEND="
	app-arch/bzip2
	net-misc/curl
	sys-libs/ncurses:0=[unicode?]
	dev-libs/openssl:0
	sys-libs/readline:0
	dev-db/sqlite:3
	sys-libs/zlib

	pcre? ( dev-libs/libpcre[cxx] )"
DEPEND="${RDEPEND}
	sys-apps/gawk
	dev-util/re2c

	test? ( ${PYTHON_DEPS} )"

src_prepare() {
	default

	# respect AR
	sed -r -e '/^AR *= */d' -i -- src/Makefile.in || die
}

src_configure() {
	local myeconfargs=(
		--disable-static
		# experimental support, available since v0.7.3
		--without-jemalloc
		--with-ncurses

		$(use_enable static)

		$(use_with pcre)
		$(use_with readline)
		$(use_with unicode ncursesw)
	)
	econf "${myeconfargs[@]}"
}

## Tests
# Fail: test_listview.sh, test_mvwattrline.sh, test_view_colors.sh

src_install() {
	default

	# the text that appears after pressing `?` in TUI
	dodoc src/help.txt
}
