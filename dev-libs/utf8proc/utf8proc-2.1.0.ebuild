# Copyright 1999-2016 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_URI="github/JuliaLang"
GH_REF="v${PV}"

inherit git-hosting

DESCRIPTION="mapping tool for UTF-8 strings"
HOMEPAGE="http://julialang.org/utf8proc/ ${GH_HOMEPAGE}"
LICENSE="MIT unicode"

# subslot follows ABI version number, which is defined in `Makefile` or `CMakeLists.txt`
SLOT="0/${PV}"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE="static-libs"

src_prepare() {
	eapply_user

	sed -r -e '/CFLAGS = / s, -(O2|pedantic),,g' \
		-i -- Makefile || die
}

src_install() {
	emake install \
		DESTDIR="${ED}" \
		prefix="${EPREFIX}"/usr \
		includedir="${EPREFIX}"/usr/include \
		libdir="${EPREFIX}/usr/$(get_libdir)"

	einstalldocs
	dodoc NEWS.md

	use static-libs || erm "${ED}/usr/$(get_libdir)/lib${PN}.a"
}
