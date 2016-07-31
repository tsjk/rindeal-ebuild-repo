# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{2_7,3_{4,5}} )
PYTHON_REQ_USE="threads"

DISTUTILS_OPTIONAL=true
DISTUTILS_IN_SOURCE_BUILD=true

GH_URI='github/arvidn/libtorrent'
GH_REF="libtorrent-${PV//./_}"

inherit autotools git-hosting distutils-r1

DESCRIPTION='C++ BitTorrent implementation focusing on efficiency and scalability'
HOMEPAGE='http://libtorrent.org'
LICENSE='BSD'

SONAME='8'
SLOT="0/${SONAME}"

KEYWORDS='~amd64 ~arm'
RESTRICT+=' test'
IUSE='+crypt debug +dht doc examples python static-libs test'
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

RDEPEND="
	!net-libs/rb_libtorrent
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

src_prepare() {
	default

	# make sure lib search dir points to the main `S` dir and not to python copies
	sed -i "s|-L[^ ]*/src/\.libs|-L${S}/src/.libs|" \
		-- 'bindings/python/link_flags.in' || die

	# needed or else eautoreconf fails
	mkdir build-aux && cp {m4,build-aux}'/config.rpath' || die

	eautoreconf

	use python && distutils-r1_src_prepare
}

src_configure() {
	local econfargs=(
		'--disable-silent-rules' # bug 441842
		'--with-boost-system=mt'
		'--with-libiconv'
		$(use_enable crypt encryption)
		$(use_enable debug)
		$(usex debug '--enable-logging=verbose' '')
		$(use_enable dht)
		$(use_enable examples)
		$(use_enable static-libs static)
		$(use_enable test tests)
	)
	econf "${econfargs[@]}"

	python_configure() {
		local econfargs+=(
			'--enable-python-binding'
			'--with-boost-python=yes'
		)
		econf "${econfargs[@]}"
	}
	use python && distutils-r1_src_configure
}

src_compile() {
	default

	python_compile() {
		cd "${BUILD_DIR}/../bindings/python" || die
		distutils-r1_python_compile
	}
	use python && distutils-r1_src_compile
}

src_install() {
	use doc && HTML_DOCS+=( "${S}/docs" )

	default

	python_install() {
		cd "${BUILD_DIR}/../bindings/python" || die
		distutils-r1_python_install
	}
	use python && distutils-r1_src_install
}
