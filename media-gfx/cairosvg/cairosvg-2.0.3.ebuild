# Copyright 1999-2015 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:Kozea:CairoSVG"

PYTHON_COMPAT=( python3_{4,5} )

inherit git-hosting
inherit distutils-r1

DESCRIPTION="Simple cairo based SVG converter with support for PDF, PostScript and PNG"
HOMEPAGE="http://cairosvg.org/ ${GH_HOMEPAGE}"
LICENSE="LGPL-3"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"

CDEPEND_A=(
	"dev-python/lxml[${PYTHON_USEDEP}]"
	"dev-python/pycairo[${PYTHON_USEDEP}]"
	"dev-python/tinycss[${PYTHON_USEDEP}]"
	"dev-python/cssselect[${PYTHON_USEDEP}]"
	"dev-python/cairocffi[${PYTHON_USEDEP}]"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

DOCS=( NEWS.rst README.rst TODO.rst )
