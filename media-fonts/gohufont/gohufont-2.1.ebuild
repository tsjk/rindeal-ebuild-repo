# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

FONT_SUFFIX="pcf.gz"

# EXPORT_FUNCTIONS: pkg_setup src_install pkg_postinst pkg_postrm
inherit font

DESCRIPTION="Monospace bitmap font inspired by Terminus, available in 11-px and 14-px heights"
HOMEPAGE="http://font.gohu.org/ http://font.gohu.eu https://github.com/hchargois/gohufont"
LICENSE="WTFPL-2"

SLOT="0"
SRC_URI="http://font.gohu.org/${P}.tar.gz"

KEYWORDS="amd64 arm arm64"

DOCS="README.md"
