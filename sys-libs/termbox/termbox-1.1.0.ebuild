# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

## git-hosting.eclass
GH_URI="github/nsf"
GH_REF="v${PV}"
## python-*.eclass
PYTHON_COMPAT=( python{2_7,3_4} )
# threads are for waf
PYTHON_REQ_USE="threads"
## distutils-r1.eclass
DISTUTILS_OPTIONAL=TRUE

inherit git-hosting python-r1 distutils-r1 waf-utils

DESCRIPTION="Library for writing text-based user interfaces"
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64 ~arm"
IUSE="examples python static-libs"

CDEPEND="python? ( ${PYTHON_DEPS} )"
DEPEND="${CDEPEND}
	python? ( dev-python/cython[${PYTHON_USEDEP}] )"
RDEPEND="${CDEPEND}"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

pkg_setup() {
	python_setup
}

src_prepare() {
	default

	# respect flags
	sed -e '/CFLAGS/ s@-O[0-9]@@' \
		-i -- wscript || die
	# fix compiler error
	# https://github.com/nsf/termbox/issues/89
	sed -e 's@extra_compile_args=\["@&-D_XOPEN_SOURCE", "@' \
		-i -- setup.py || die
	# do not build examples
	sed -e '/bld.recurse("demo")/d' \
		-i -- src/wscript || die

	use python && \
		distutils-r1_src_prepare
}

src_configure() {
	waf-utils_src_configure
	use python && \
		distutils-r1_src_configure
}

src_compile() {
	waf-utils_src_compile
	use python && \
		distutils-r1_src_compile
}

src_install() {
	local waf=( "${WAF_BINARY}"
		--destdir="${D}"
		--targets=$(usex static-libs 'termbox_static,' '')termbox_shared
		install
	)
	echo "${waf[@]}"
	"${waf[@]}" || die

	use python && \
		distutils-r1_src_install

	## docs
	einstalldocs

	docinto tools
	dodoc tools/*.py

	if use examples ; then
		docinto demo
		dodoc src/demo/*.c
	fi
}
