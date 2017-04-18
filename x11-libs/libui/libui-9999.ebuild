# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:andlabs"

# EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
inherit cmake-utils

DESCRIPTION="Simple and portable GUI library in C that uses the native GUI technologies"
LICENSE="MIT"

# subslots follow SONAME
SLOT="0/0"

[[ "${PV}" != *9999* ]] && KEYWORDS="~amd64 ~arm ~arm64"

CDEPEND_A=(
	">=x11-libs/gtk+-3.10:3"
)
DEPEND_A=()
RDEPEND_A=()

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=YES
	)

	cmake-utils_src_configure
}

src_install() {
	local libdir="${ED}/usr/$(get_libdir)"
	epushd "${BUILD_DIR}"
	emkdir "${libdir}"
	ecp --no-dereference out/${PN}.so* "${libdir}"
	epopd

	doheader ui.h ui_unix.h

	local DOCS=( ANNOUNCE.md Changelog.md Compatibility.md README.md TODO.md )
	einstalldocs
}
