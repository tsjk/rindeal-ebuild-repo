# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

PYTHON_COMPAT=( python2_7 python3_{3,4} )

GH_RN='github:gpocentek:python-gitlab'

inherit distutils-r1
inherit git-hosting

DESCRIPTION="Python wrapper for the GitLab API"
HOMEPAGE="https://python-gitlab.readthedocs.io ${GH_HOMEPAGE}"
LICENSE="LGPL-3"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE="man test"

DEPEND_A=(
	"man? ( dev-python/sphinx )"
	"test? ("
		"dev-python/coverage"
		"dev-python/testrepository"
		">=dev-python/hacking-0.9.2"
		"<dev-python/hacking-0.10"
		"dev-python/httmock"
		"dev-python/jinja"
		"dev-python/mock"
		">=dev-python/sphinx-1.3"
	")"
)
RDEPEND_A=(
	">dev-python/requests-1"
	"dev-python/six"
)

inherit arrays

src_prepare() {
	default

	use test || \
		erm -r 'gitlab/tests'
}

python_compile_all() {
	use man && \
		emake -C docs man
}

python_test() {
	esetup.py testr
}

python_install_all() {
	distutils-r1_python_install_all

	use man && \
		doman 'docs/_build/man/python-gitlab.1'
}
