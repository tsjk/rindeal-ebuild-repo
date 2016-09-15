# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{2_7,3_{4,5}} )
PYTHON_REQ_USE="threads"

DISTUTILS_OPTIONAL=true
DISTUTILS_IN_SOURCE_BUILD=true

gh_repo='arvidn/libtorrent'

inherit vcs-snapshot distutils-r1 eutils

DESCRIPTION='C++ BitTorrent implementation focusing on efficiency and scalability'
HOMEPAGE="http://libtorrent.org https://github.com/${gh_repo}"
LICENSE='BSD'

SONAME='8'
SLOT="0/${SONAME}"
SRC_URI="https://github.com/${gh_repo}/releases/download/libtorrent-${PV//./_}/${P}.tar.gz"

KEYWORDS='~amd64 ~arm'
IUSE='+crypt debug +dht doc examples python static-libs test'

RDEPEND="
	!!net-libs/rb_libtorrent
	dev-libs/boost:=[threads]
	virtual/libiconv

	crypt? ( dev-libs/openssl:0= )
	examples? ( !net-p2p/mldonkey )
	python? ( ${PYTHON_DEPS}
		dev-libs/boost:=[python,${PYTHON_USEDEP}]
	)"
DEPEND="${RDEPEND}
	sys-devel/libtool"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"
RESTRICT+=" test"

src_prepare() {
	default

	# https://github.com/rindeal/gentoo-overlay/issues/28
	# make sure lib search dir points to the main `S` dir and not to python copies
	sed -e "s|-L[^ ]*/src/\.libs|-L${S}/src/.libs|" \
		-i -- bindings/python/link_flags.in || die

	# respect optimization flags
	sed -e '/FLAGS *=/ s|-Os||' \
		-i configure CMakeLists.txt || die

	use python && distutils-r1_src_prepare
}

src_configure() {
	local myeconfargs=(
		--disable-silent-rules # bug 441842
		# hardcode boost system to skip "lookup heuristic"
		--with-boost-system='mt'
		--with-libiconv

		$(use_enable crypt encryption)
		$(use_enable debug)
		$(use_enable debug disk-stats)
		$(use_enable debug logging verbose)
		$(use_enable debug statistics)
		$(use_enable dht dht $(usex debug logging yes))
		$(use_enable examples)
		$(use_enable static-libs static)
		$(use_enable test tests)
	)
	econf "${myeconfargs[@]}"

	if use python ; then
		python_configure() {
			local myeconfargs=( "${myeconfargs[@]}"
				--enable-python-binding
				--with-boost-python
			)
			econf "${myeconfargs[@]}"
		}
		distutils-r1_src_configure
	fi
}

src_compile() {
	default

	if use python ; then
		python_compile() {
			cd "${BUILD_DIR}"/../bindings/python || die
			distutils-r1_python_compile
		}
		distutils-r1_src_compile
	fi
}

src_install() {
	use doc && local HTML_DOCS+=( ./docs )

	default

	if use python ; then
		python_install() {
			cd "${BUILD_DIR}"/../bindings/python || die
			distutils-r1_python_install
		}
		distutils-r1_src_install
	fi

	prune_libtool_files
}
