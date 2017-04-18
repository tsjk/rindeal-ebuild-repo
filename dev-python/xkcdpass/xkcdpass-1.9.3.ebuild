# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:redacted:XKCD-password-generator"
GH_REF="${PN}-${PV}"

PYTHON_COMPAT=( python{2_7,3_3,3_4,3_5} )

inherit git-hosting
inherit distutils-r1
# functions: newbashcomp
inherit bash-completion-r1

DESCRIPTION="Flexible and scriptable password generator, inspired by XKCD 936"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE="examples"

python_install_all() {
	distutils-r1_python_install_all

	doman "${PN}.1"

	newbashcomp "contrib/${PN}.bash-completion" "${PN}"

	use examples && dodoc -r examples
}
