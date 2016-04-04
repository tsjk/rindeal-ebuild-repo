# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit git-r3

DESCRIPTION="Command line interface client for Telegram"
HOMEPAGE="https://github.com/vysheng/tg"
LICENSE="GPL-2"
EGIT_REPO_URI="https://github.com/vysheng/tg.git"

SLOT="0"
KEYWORDS="~amd64 ~arm"
IUSE="lua json python"

DEPEND="sys-libs/zlib
	sys-libs/readline:*
	dev-libs/libconfig
	dev-libs/openssl:=
	dev-libs/libevent
	lua? ( dev-lang/lua:* dev-lua/lgi )
	json? ( dev-libs/jansson )
	python? ( dev-lang/python:* )"
RDEPEND="${DEPEND}"

src_configure() {
	sed -i -r -e 's| -ggdb||' -- {,tgl/{,tl-parser/}}Makefile.in || die

	local econfargs=(
		'--disable-valgrind'
		$(use_enable lua liblua)
		$(use_enable python)
		$(use_enable json)
	)
	econf "${econfargs[@]}"
}

src_install() {
	dobin "bin/${PN}"

	insinto "/etc/${PN}"
	newins {,tg-}server.pub

	einstalldocs
}
