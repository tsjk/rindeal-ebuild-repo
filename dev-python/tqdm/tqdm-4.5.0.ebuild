# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python{2_7,3_{3,4,5}} )

GH_TAG="v${PV}"

inherit github distutils-r1

DESCRIPTION='A fast, extensible progress bar for Python'
LICENSE='MPL-2.0 MIT'

SLOT='0'
KEYWORDS='~amd64 ~arm ~x86'
