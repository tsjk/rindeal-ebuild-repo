# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:python"
GH_REF="0e26c1f9361bd2d57b9f361c4fbd8185243afb21" # mypy-0.520

inherit git-hosting

DESCRIPTION="Collection of library stubs for Python, with static types"
LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"

src_configure() { :; }
src_compile() { :; }

src_install() {
	dodoc README.md

	insinto /usr/share/${PN}
	doins -r stdlib third_party
}
