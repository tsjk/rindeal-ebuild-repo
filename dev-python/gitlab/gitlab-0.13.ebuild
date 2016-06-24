# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{3,4} )

GH_URI='github/gpocentek/python-gitlab'

inherit distutils-r1 git-hosting

DESCRIPTION="Python wrapper for the GitLab API"
HOMEPAGE+=" https://python-gitlab.readthedocs.io"
LICENSE="LGPL-3"

SLOT="0"

KEYWORDS="~amd64 ~x86"
IUSE="test"

DEPEND="
	dev-python/sphinx
	test? (
		dev-python/coverage
		dev-python/testrepository
		>=dev-python/hacking-0.9.2
		<dev-python/hacking-0.10
		dev-python/httmock
		dev-python/jinja
		dev-python/mock
		>=dev-python/sphinx-1.3
	)
"
RDEPEND="
	>dev-python/requests-1
	dev-python/six"

src_prepare() {
	default

	use test || rm -rvf 'gitlab/tests'
}

python_compile_all() {
	emake -C docs man
}

python_test() {
	esetup.py testr
}

python_install_all() {
	distutils-r1_python_install_all

	doman 'docs/_build/man/python-gitlab.1'
}
