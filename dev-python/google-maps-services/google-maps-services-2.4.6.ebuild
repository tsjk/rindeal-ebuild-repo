# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:googlemaps:${PN}-python"
PYTHON_COMPAT=( python{2_7,3_4} )

inherit distutils-r1
inherit git-hosting

DESCRIPTION="Python client library for Google Maps API Web Services"
LICENSE="Apache-2.0"

SLOT="0"

# ~arm/~arm64 is missing dev-python/responses package
KEYWORDS="~amd64"
IUSE="test"

CDEPEND="<=dev-python/requests-2.10.0[${PYTHON_USEDEP}]"
DEPEND="${CDEPEND}
	test? (
		dev-python/nose[${PYTHON_USEDEP}]
		dev-python/responses[${PYTHON_USEDEP}]
	)"
RDEPEND="${CDEPEND}"

python_test() {
	nosetests --verbosity=3 || die
}
