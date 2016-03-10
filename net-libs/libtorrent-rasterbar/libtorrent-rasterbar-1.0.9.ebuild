# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5} )
PYTHON_REQ_USE="threads"
DISTUTILS_OPTIONAL=true

inherit distutils-r1

MY_PV="${PV//./_}"

DESCRIPTION="C++ BitTorrent implementation focusing on efficiency and scalability"
HOMEPAGE="http://libtorrent.org"
LICENSE="BSD"
SRC_URI="https://github.com/arvidn/libtorrent/archive/libtorrent-${MY_PV}.tar.gz -> ${P}.tar.gz"

SLOT="0"
KEYWORDS="~amd64 ~arm"
RESTRICT="test"

IUSE="debug doc examples python ssl static-libs test"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

RDEPEND="
	!net-libs/rb_libtorrent
	>=dev-libs/boost-1.53:=[threads]
	sys-libs/zlib
	examples? ( !net-p2p/mldonkey )
	ssl? ( dev-libs/openssl:0= )
	python? (
		${PYTHON_DEPS}
		dev-libs/boost:=[python,${PYTHON_USEDEP}]
	)"
DEPEND="${RDEPEND}
	>=sys-devel/libtool-2.2"

S=${WORKDIR}/libtorrent-libtorrent-${MY_PV}

src_prepare() {
	# python2 -> 2/3
	sed -i -r -e "s|execfile\('([^']*)'\)|exec(open('\1').read())|" -- 'setup.py' || die

	default
	./autotool.sh
}

src_configure() {
	use python && python_setup

	local econfargs=(
		--disable-silent-rules # bug 441842
		--with-boost-system=mt
		$(use_enable debug)
		$(use_enable test tests)
		$(use_enable examples)
		$(use_enable ssl encryption)
		$(use_enable python python-binding)
		$(usex debug '--enable-logging=verbose' '')
		$(usex python_targets_python2_7 '--with-boost-python=2.7' '')
	)
	if use python_targets_python3_3 ;then
		econfargs+=( '--with-boost-python=3.3' )
	elif use python_targets_python3_4 ;then
		econfargs+=( '--with-boost-python=3.4' )
	elif use python_targets_python3_5 ;then
		econfargs+=( '--with-boost-python=3.5' )
	fi

	econf "${econfargs[@]}"
	use python && distutils-r1_src_configure
}

src_compile() {
	default
	use python && distutils-r1_src_compile
}

src_install() {
	default
	use python && distutils-r1_src_install

	use doc && HTML_DOCS=( "${S}"/docs )
	einstalldocs
}
