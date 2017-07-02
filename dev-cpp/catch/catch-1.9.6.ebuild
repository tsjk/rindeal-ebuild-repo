# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:philsquared:Catch"
GH_REF="v${PV}"

inherit cmake-utils
inherit git-hosting

DESCRIPTION="Modern C++ header-only framework for unit-tests"
LICENSE="Boost-1.0"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE="doc"

# CMake is only used to build & run tests, so override phases
src_configure() { :; }
src_compile() { :; }

src_test() {
	cmake-utils_src_configure
	cmake-utils_src_compile
	cmake-utils_src_test
}

src_install() {
	# same location as used in fedora
	insinto /usr/include/catch
	doins -r include/.

	use doc && dodoc -r docs/.
}
