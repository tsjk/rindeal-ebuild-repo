# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{2_7,3_{4,5}} )
PYTHON_REQ_USE="threads"

DISTUTILS_OPTIONAL=true
DISTUTILS_IN_SOURCE_BUILD=true

GH_URI='github/arvidn/libtorrent'
#GH_REF="libtorrent-${PV//./_}"
GH_REF="libtorrent-1_1"

inherit autotools git-hosting distutils-r1

DESCRIPTION='C++ BitTorrent implementation focusing on efficiency and scalability'
HOMEPAGE='http://libtorrent.org'
LICENSE='BSD'

SONAME='9'
SLOT="0/${SONAME}"

KEYWORDS='~amd64 ~arm'
IUSE='+crypt debug +dht doc examples python static-libs test'

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

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"
RESTRICT+=' test'

src_prepare() {
	PATCHES=(
		"${FILESDIR}"/1.1.0-remove__msse4_2_commandline_option_from_configure_script.patch # remove in >1.1.0
	)
	default

	# make sure lib search dir points to the main `S` dir and not to python copies
	sed -e "s|-L[^ ]*/src/\.libs|-L${S}/src/.libs|" \
		-i -- 'bindings/python/link_flags.in' || die

	# needed or else eautoreconf fails
	mkdir build-aux && cp {m4,build-aux}'/config.rpath' || die

	eautoreconf

	use python && distutils-r1_src_prepare
}

src_configure() {
	local econf_args=(
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
	econf "${econf_args[@]}"

	python_configure() {
		local econf_args=( "${econf_args[@]}"
			--enable-python-binding
			--with-boost-python='yes'
		)
		econf "${econf_args[@]}"
	}
	use python && distutils-r1_src_configure
}

src_compile() {
	default

	python_compile() {
		cd "${BUILD_DIR}"/../bindings/python || die
		distutils-r1_python_compile
	}
	use python && distutils-r1_src_compile
}

src_install() {
	use doc && HTML_DOCS+=( "${S}"/docs )

	default

	python_install() {
		cd "${BUILD_DIR}"/../bindings/python || die
		distutils-r1_python_install
	}
	use python && distutils-r1_src_install
}
