# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:embedthis"
GH_REF="v${PV}"

inherit git-hosting

DESCRIPTION="A modern replacement for autoconf/make"
HOMEPAGE="https://embedthis.com/makeme ${GH_HOMEPAGE}"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE="debug"


CDEPEND="
	dev-libs/libpcre
	sys-libs/zlib"
DEPEND="${CDEPEND}"
RDEPEND="${CDEPEND}"

bootstrap() {
	epushd "${S}"

	einfo "Bootstrapping ..."

	CFLAGS="" ME_ROOT_PREFIX="${EPREFIX}" SHOW=1 emake -j1 boot
	export PATH="${S}"/build/*-release/bin:"${PATH}"

	einfo "Bootstrapping finished ..."

	epopd
}

src_prepare() {
	default

	sed -r -e 's|^(DFLAGS.*+=.*)-DME_DEBUG[^ \t]*(.*)|\1\2|' -i -- projects/makeme-linux-default.mk || die
	sed -r -e '/^(C|D|LD)FLAGS.*+=.*$(DEBUG)/d' -i -- projects/makeme-linux-default.mk || die
	sed -r -e 's|(/bin/me )|\1--verbose --show |' -i -- Makefile || die

	has_version "${CATEGORY}/${PN}" || bootstrap
}

src_configure() {
	local econf_args=(
		--verbose --show
		--unicode
		--profile $(usex debug 'debug' 'release')
	)
	econf "${econf_args[@]}"
}
