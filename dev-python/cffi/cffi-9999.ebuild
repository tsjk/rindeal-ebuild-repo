# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# DO NOT ADD pypy to PYTHON_COMPAT
# pypy bundles a modified version of cffi. Use python_gen_cond_dep instead.
PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit distutils-r1
inherit vcs-snapshot

DESCRIPTION="Foreign Function Interface for Python calling C code"
HOMEPAGE="http://cffi.readthedocs.org/ https://pypi.python.org/pypi/cffi"
LICENSE="MIT"

SLOT="0/${PV}"
if [[ ${PV} == *9999* ]] ; then
	commit=2f3c1c5
	# https://bitbucket.org/cffi/cffi/downloads/?tab=tags
	SRC_URI="https://bitbucket.org/cffi/cffi/get/${commit}.tar.bz2"
	S="${WORKDIR}/${commit}"
else
	SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64"
fi

IUSE="doc test"

RDEPEND="
	virtual/libffi
	dev-python/pycparser[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? ( dev-python/sphinx[${PYTHON_USEDEP}] )
	test? (	dev-python/pytest[${PYTHON_USEDEP}] )"

# Avoid race on _configtest.c (distutils/command/config.py:_gen_temp_sourcefile)
DISTUTILS_IN_SOURCE_BUILD=1

python_compile_all() {
	use doc && emake -C doc html
}

python_test() {
	einfo "$PYTHONPATH"
	$PYTHON -c "import _cffi_backend as backend" || die
	PYTHONPATH="${PYTHONPATH}" \
	py.test -x -v \
		--ignore testing/test_zintegration.py \
		--ignore testing/embedding \
		c/ testing/ \
		|| die "Testing failed with ${EPYTHON}"
}

python_install_all() {
	use doc && local HTML_DOCS=( doc/build/html/. )
	distutils-r1_python_install_all
}
