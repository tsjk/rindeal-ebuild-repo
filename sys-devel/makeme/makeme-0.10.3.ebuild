# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

DESCRIPTION="A modern replacement for autoconf/make"
HOMEPAGE="https://embedthis.com/makeme"
LICENSE="GPL-2"
SRC_URI="https://github.com/embedthis/makeme/archive/v0.10.3.tar.gz -> ${P}.tar.gz"

SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE="debug"

DEPEND="
	dev-libs/libpcre
	sys-libs/zlib"
RDEPEND="${DEPEND}"

bootstrap() {
	pushd "${S}" &>/dev/null || return 1
	
	elog "Bootstrapping ..."

	CFLAGS="" emake -j1 SHOW=1 boot
	export PATH="${S}"/build/*-release/bin:"${PATH}"

	popd &>/dev/null || return 1
}

src_prepare() {
	default
	
	has_version "${CATEGORY}/${PN}" || bootstrap || die
}

src_configure() {
	econf_args=(
		--verbose --show
		--unicode
		--profile $(usex debug 'debug' 'release')
	)
	econf "${econf_args[@]}"
}
