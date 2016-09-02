# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{2_7,3_{4,5}} )
PYTHON_REQ_USE="threads"

DISTUTILS_OPTIONAL=true
DISTUTILS_IN_SOURCE_BUILD=true

GH_URI='github/arvidn/libtorrent'

inherit git-hosting distutils-r1

DESCRIPTION='C++ BitTorrent implementation focusing on efficiency and scalability'
HOMEPAGE="http://libtorrent.org ${HOMEPAGE}"
LICENSE='BSD'

SONAME='8'
SLOT="0/${SONAME}"
SRC_URI="https://github.com/arvidn/libtorrent/releases/download/libtorrent-${PV//./_}/${P}.tar.gz"

KEYWORDS='~amd64 ~arm'
IUSE='+crypt debug +dht doc examples python static-libs test'

RDEPEND="
	!!net-libs/rb_libtorrent
	>=dev-libs/boost-1.53:=[threads]
	sys-libs/zlib
	virtual/libiconv
	crypt? ( dev-libs/openssl:0= )
	examples? ( !net-p2p/mldonkey )
	python? ( ${PYTHON_DEPS}
		dev-libs/boost:=[python,${PYTHON_USEDEP}]
	)"
DEPEND="${RDEPEND}
	>=sys-devel/libtool-2.2"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"
RESTRICT+=' test'

src_prepare() {
	default

	# make sure lib search dir points to the main `S` dir and not to python copies
	sed -e "s|-L[^ ]*/src/\.libs|-L${S}/src/.libs|" \
		-i -- 'bindings/python/link_flags.in' || die

	use python && distutils-r1_src_prepare
}

src_configure() {
	local myeconfargs=(
		--disable-silent-rules # bug 441842
		--with-boost-system='mt'
		--with-libiconv
		$(use_enable crypt encryption)
		$(use_enable debug)
		$(usex debug '--enable-logging=verbose' '')
		$(use_enable dht)
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
	use doc && HTML_DOCS+=( "${S}"/docs )

	default

	if use python ; then
		python_install() {
			cd "${BUILD_DIR}"/../bindings/python || die
			distutils-r1_python_install
		}
		distutils-r1_src_install
	fi
}
