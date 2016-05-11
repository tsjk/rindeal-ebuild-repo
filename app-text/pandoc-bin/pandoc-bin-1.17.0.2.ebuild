# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit unpacker

MY_PN="${PN//-bin/}"

DESCRIPTION="Universal markup converter"
HOMEPAGE="http://pandoc.org"
LICENSE="GPL-2"
SRC_URI="https://github.com/jgm/pandoc/releases/download/${PV}/${MY_PN}-${PV}-1-amd64.deb"

SLOT="0"
RESTRICT="mirror strip"
KEYWORDS="-* ~amd64"
IUSE="citeproc"

DEPEND="
	dev-libs/gmp:*
	sys-libs/zlib:*"
RDEPEND="${DEPEND}
	!app-text/pandoc
	citeproc? ( !dev-haskell/pandoc-citeproc )"

S="${WORKDIR}"

src_prepare() {
	default

	# docs are gzipped
	find -name "*.gz" | xargs gunzip
	assert
}

src_install() {
	cd "${S}/usr/bin" || die
	dobin "${MY_PN}"
	use citeproc && dobin 'pandoc-citeproc'

	cd "${S}/usr/share/man/man1" || die
	doman "${MY_PN}.1"
	use citeproc && doman 'pandoc-citeproc.1'
}
