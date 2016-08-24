# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GH_URI="github/redacted/XKCD-password-generator"
GH_REF="${PN}-${PV}"

PYTHON_COMPAT=( python{2_7,3_3,3_4,3_5} )

inherit git-hosting distutils-r1 bash-completion-r1

DESCRIPTION="A flexible and scriptable password generator, inspired by XKCD 936"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm"
IUSE="examples"

DEPEND=""
RDEPEND="${DEPEND}"

python_install_all() {
	distutils-r1_python_install_all

	doman "${PN}.1"
	newbashcomp "contrib/${PN}.bash-completion" "${PN}"

	use examples && dodoc -r examples
}
