# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

inherit flag-o-matic
inherit cuda
inherit autotools
inherit versionator
inherit toolchain-funcs

DESCRIPTION="displays the hardware topology in convenient formats"
HOMEPAGE="https://www.open-mpi.org/projects/hwloc/"
LICENSE="BSD"

SLOT="0/5"
MY_PV="v$(get_version_component_range 1-2)"
SRC_URI="https://www.open-mpi.org/software/${PN}/${MY_PV}/downloads/${P}.tar.bz2"

KEYWORDS="amd64 arm arm64"
IUSE="cairo debug gl +numa opencl +pci plugins svg static-libs xml X"

# TODO opencl only works with AMD so no virtual
# dev-util/nvidia-cuda-toolkit is always multilib

CDEPEND=">=sys-libs/ncurses-5.9-r3:0
	cairo? ( >=x11-libs/cairo-1.12.14-r4[X?,svg?] )
	gl? ( || ( x11-drivers/nvidia-drivers[static-libs,tools] media-video/nvidia-settings ) )
	opencl? ( x11-drivers/ati-drivers:* )
	pci? (
		>=sys-apps/pciutils-3.3.0-r2
		>=x11-libs/libpciaccess-0.13.1-r1
	)
	plugins? ( dev-libs/libltdl:0 )
	numa? ( >=sys-process/numactl-2.0.10-r1 )
	xml? ( >=dev-libs/libxml2-2.9.1-r4 )"
DEPEND="${RDEPEND}
	>=virtual/pkgconfig-0-r1"
RDEPEND="${CDEPEND}"

src_prepare() {
	eapply "${FILESDIR}/${PN}-1.8.1-gl.patch"
	eapply_user

	eautoreconf
}

src_configure() {
	export HWLOC_PKG_CONFIG=$(tc-getPKG_CONFIG) #393467

	local myeconfargs=(
		--disable-silent-rules
		--docdir="${EPREFIX}"/usr/share/doc/${PF}
		--disable-cuda # no support for nvidia
		$(use_enable cairo)
		$(use_enable debug)
		$(multilib_native_use_enable gl)
		$(multilib_native_use_enable opencl)
		$(use_enable pci)
		$(use_enable plugins)
		$(use_enable numa libnuma)
		$(use_enable xml libxml2)
		$(use_with X x)
	)

	econf "${myeconfargs[@]}"
}
