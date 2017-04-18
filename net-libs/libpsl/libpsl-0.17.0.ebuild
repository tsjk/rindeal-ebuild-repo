# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

PYTHON_COMPAT=( python2_7 python3_{3,4,5} )

GH_RN="github:rockdaboot"
GH_REF="${PN}-${PV}"

inherit git-hosting
# functions: eautoreconf
inherit autotools
# EXPORT_FUNCTIONS: pkg_setup
inherit python-any-r1
# functions: rindeal:dsf
inherit rindeal-utils
# functions: prune_libtool_files
inherit eutils

DESCRIPTION="C library for the Publix Suffix List"
HOMEPAGE="https://rockdaboot.github.io/libpsl ${GH_HOMEPAGE}"
LICENSE="MIT"

SLOT="0"
list_commit="41a519ad34cf86ff4470b967d9e4755d72b63a6c"
list_uri=""
list_ext=""
list_distfile="${PN}-list-${list_commit}"
git-hosting_gen_snapshot_url "github:publicsuffix:list" "${list_commit}" list_url list_ext
SRC_URI+="
	${list_url} -> ${list_distfile}${list_ext}
"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( doc man static-libs nls +rpath
	+builtin +builtin_libicu builtin_libidn2 builtin_libidn
	+runtime +runtime_libicu runtime_libidn2 runtime_libidn
)

CDEPEND_A=(
	"$(rindeal:dsf \
		'(builtin & builtin_libicu) | (runtime & runtime_libicu)' \
			"dev-libs/icu[static-libs?]" )"
	"$(rindeal:dsf \
		'(builtin & builtin_libidn) | (runtime & runtime_libidn)' \
			"net-dns/libidn[static-libs?]" )"
	"$(rindeal:dsf \
		'(builtin & builtin_libidn2) | (runtime & runtime_libidn2)' \
			"net-dns/libidn2[static-libs?]" )"

	"${PYTHON_DEPS}"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"sys-devel/gettext"
	"virtual/pkgconfig"
	"sys-devel/libtool"

	"doc? ( dev-util/gtk-doc )"
	# xsltproc
	"man? ( dev-libs/libxslt )"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	"builtin? ("
		"^^ ("
			"builtin_libicu"
			"builtin_libidn"
			"builtin_libidn2"
		")"
	")"
	"runtime? ("
		"^^ ("
			"runtime_libicu"
			"runtime_libidn"
			"runtime_libidn2"
		")"
	")"
)
RESTRICT+=""

inherit arrays

MAKEOPTS+=" -j1"

src_unpack() {
	git-hosting_src_unpack

	rmdir -v "${S}/list" || die
	git-hosting_unpack "${DISTDIR}/${list_distfile}${list_ext}" "${S}/list"
}

src_prepare() {
	default

	eautoreconf
}

src_configure() {
	local myeconfargs=(
		$(use_enable doc gtk-doc)
		$(use_enable doc gtk-doc-html)
		$(use_enable doc gtk-doc-pdf)
		$(use_enable man)
		$(use_enable static-libs static)
		$(use_enable nls)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	exeinto /usr/libexec
	doexe src/psl-make-dafsa

	prune_libtool_files
}
