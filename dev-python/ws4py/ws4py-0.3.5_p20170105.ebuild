# Copyright 1999-2016 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_URI="github/Lawouach/WebSocket-for-Python"
# 2017-01-05; v0.3.5 is not tagged yet, present only on pypi
GH_REF="36da4a09e91ddd08917455fb8066d22a9617e087"

PYTHON_COMPAT=( python2_7 python3_{4,5} )
PYTHON_REQ_USE="threads?"

inherit git-hosting
inherit distutils-r1

DESCRIPTION="Client and server library for Python implementing the WebSocket protocol"
HOMEPAGE="https://ws4py.readthedocs.io  ${GH_HOMEPAGE}"
LICENSE="BSD"

SLOT="0"

KEYWORDS="amd64 arm arm64"
IUSE_A=(
	test +threads
	# 	doc # doc build requires sphinxcontrib ext packages absent from portage
	+client +server
)

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"test? ("
		">=dev-python/cherrypy-3.2.4[${PYTHON_USEDEP}]"
		"dev-python/unittest2[${PYTHON_USEDEP}]"
		">=dev-python/mock-1.0.1[${PYTHON_USEDEP}]"
	")"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	">=dev-python/greenlet-0.4.1[${PYTHON_USEDEP}]"
	"$(python_gen_cond_dep 'dev-python/gevent[${PYTHON_USEDEP}]' python2_7)"
	">=dev-python/cython-0.19.1[${PYTHON_USEDEP}]"
	"client? ( >=www-servers/tornado-3.1[${PYTHON_USEDEP}] )"
	"server? ( >=dev-python/cherrypy-3.2.4[${PYTHON_USEDEP}] )"
	# We could depend on dev-python/cherrypy when USE=server, but
	# that is an optional component ...
	# Same for www-servers/tornado and USE=client ... so why not???
)

inherit arrays

python_test() {
	# testsuite displays an issue with mock under py3 but is non fatal
	"${PYTHON}" -m unittest discover || die "Tests failed under ${EPYTHON}"
}

python_install() {
	distutils-r1_python_install
	use client || rm -rf "${ED}$(python_get_sitedir)"/ws4py/client
	use server || rm -rf "${ED}$(python_get_sitedir)"/ws4py/server
}

python_install_all() {
	distutils-r1_python_install_all

	dodoc CHANGELOG.txt
}
