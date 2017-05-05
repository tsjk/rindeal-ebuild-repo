# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github"

inherit autotools
inherit git-hosting

DESCRIPTION="Terminal multiplexer"
HOMEPAGE="https://tmux.github.io/ ${GH_HOMEPAGE}"
LICENSE="ISC"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE="debug selinux utempter utf8proc static"

CDEPEND="
	dev-libs/libevent:0=
	|| (
		=dev-libs/libevent-2.0*
		>=dev-libs/libevent-2.1.5-r4
	)
	utempter? ( sys-libs/libutempter )
	utf8proc? ( dev-libs/utf8proc )
	sys-libs/ncurses:0="
DEPEND="${CDEPEND}
	virtual/pkgconfig"
RDEPEND="${CDEPEND}
	dev-libs/libevent:=
	selinux? ( sec-policy/selinux-screen )
"

src_prepare() {
	eapply_user

	sed -r -e '/^(AM_)?CFLAGS/ s, -(O2|g),,g' -i Makefile.am || die

	eautoreconf
}

src_configure() {
	local my_econf_args=(
		# configure.ac overrides it otherwise
		--sysconfdir="${EPREFIX}"/etc

		$(use_enable debug)
		$(use_enable static)

		$(use_enable utempter)
		$(use_enable utf8proc)
	)
	econf "${my_econf_args[@]}"

}

src_install() {
	default

	dodoc example_tmux.conf

	insinto /usr/share/vim/vimfiles/ftdetect
	doins "${FILESDIR}"/tmux.vim
}
