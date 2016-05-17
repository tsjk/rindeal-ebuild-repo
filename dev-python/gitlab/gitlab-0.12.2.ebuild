# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{3,4} )

inherit distutils-r1 python-r1

MY_PN="python-gitlab"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Python wrapper for the GitLab API"
HOMEPAGE="https://github.com/gpocentek/python-gitlab"
LICENSE="LGPL-3"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE="test"

RDEPEND="
	>dev-python/requests-1
	dev-python/six"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	use test || rm -rvf 'gitlab/tests'

	default
}
