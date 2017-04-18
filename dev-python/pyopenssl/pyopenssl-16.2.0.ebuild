# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:pyca"

PYTHON_COMPAT=( python2_7 python3_{4,5} pypy{,3} )
PYTHON_REQ_USE="threads(+)"

inherit distutils-r1
inherit flag-o-matic
inherit git-hosting

DESCRIPTION="Python interface to the OpenSSL library"
HOMEPAGE="
	${GH_HOMEPAGE}
	https://pypi.python.org/pypi/pyOpenSSL
	https://pyopenssl.readthedocs.io/en/${PV}/
	http://pyopenssl.org/
"
LICENSE="Apache-2.0"

SLOT="0"
KEYWORDS="amd64 arm arm64"
IUSE="doc examples test"

CDEPEND="
	>=dev-python/six-1.5.2[${PYTHON_USEDEP}]
	>=dev-python/cryptography-1.3[${PYTHON_USEDEP}]"
DEPEND="${CDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
	doc? ( dev-python/sphinx[${PYTHON_USEDEP}] )
	test? (
		virtual/python-cffi[${PYTHON_USEDEP}]
		>=dev-python/pytest-3.0.1[${PYTHON_USEDEP}] )"
RDEPEND="${CDEPEND}"

python_compile_all() {
	use doc && emake -C doc html
}

python_test() {
	# FIXME: for some reason, no-ops on PyPy
	esetup.py test
}

python_install_all() {
	use doc && local HTML_DOCS=( doc/_build/html/. )
	if use examples ; then
		docinto examples
		dodoc -r examples/*
		docompress -x /usr/share/doc/${PF}/examples
	fi

	distutils-r1_python_install_all
}
