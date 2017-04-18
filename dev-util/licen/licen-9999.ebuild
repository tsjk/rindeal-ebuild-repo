# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{2_7,3_{3,4,5}} )

DISTUTILS_SINGLE_IMPL=true

GH_RN='github:lord63'

inherit git-hosting distutils-r1

DESCRIPTION='Licence file generator. Yet another lice, but implemented with Jinja2 and docopt'
LICENSE='MIT'

SLOT='0'
KEYWORDS='~amd64 ~arm ~x86'

RDEPEND="
	dev-python/docopt:0[${PYTHON_USEDEP}]
	dev-python/jinja:0[${PYTHON_USEDEP}]
"
