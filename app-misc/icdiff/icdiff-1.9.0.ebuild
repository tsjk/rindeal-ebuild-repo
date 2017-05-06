# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

PYTHON_COMPAT=( python{2_7,3_4,3_5} )

GH_RN="github:jeffkaufman"
GH_REF="release-${PV}"

inherit python-single-r1
inherit git-hosting

DESCRIPTION="Colourized diff that supports side-by-side diffing"
HOMEPAGE="https://www.jefftk.com/icdiff ${HOMEPAGE}"
LICENSE="PSF-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"

CDEPEND="${PYTHON_DEPS}"
DEPEND="${CDEPEND}"
RDEPEND="${CDEPEND}"

REQUIRED_USE+=" ${PYTHON_REQUIRED_USE}"

src_test() {
	./test.sh "${EPYTHON%.*}" || die "Tests failed"
}

src_install() {
	dobin ${PN} git-${PN}

	einstalldocs
}
