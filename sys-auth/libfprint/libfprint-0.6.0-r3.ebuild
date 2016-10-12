# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit rindeal
# EXPORT_FUNCTIONS: src_unpack
inherit vcs-snapshot
# functions: eautoreconf
inherit autotools
# functions: prune_libtool_files
inherit eutils
# functions: get_udevdir
inherit udev

DESCRIPTION="Library for fingerprint reader support"
HOMEPAGE="https://cgit.freedesktop.org/${PN}/${PN}"
LICENSE="LGPL-2.1"

# NOTE: upstream changes case of the 'v' letter from time to time
MY_PV="V_${PV//./_}"
SLOT="0"
SRC_URI="https://cgit.freedesktop.org/${PN}/${PN}/snapshot/${MY_PV}.tar.bz2 -> ${P}.tar.bz2"

# no arm until profiles are set up
KEYWORDS="~amd64"
IUSE="debug examples static-libs validity-driver"

CDEPEND_A=(
	"virtual/libusb:1"
	"dev-libs/glib:2"
	"dev-libs/nss"
	"x11-libs/pixman"
	"virtual/udev" )
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	"validity-driver? ( sys-auth/validity-sensor )" )

inherit arrays

src_prepare() {
	# these pacthes are non-intrusive so do not make them conditional
	cp -v -r "${FILESDIR}/validity-driver" "libfprint/drivers/validity" || die
	eapply "${FILESDIR}/vcsFPService_driver.patch"

	eapply_user

	# upeke2 and fdu2000 were missing from all_drivers.
	sed -e '/^all_drivers=/s:"$: upeke2 fdu2000":' \
		-i -- configure.ac || die

	eautoreconf
}

src_configure() {
	local myeconfargs=(
		# TODO: split to USE=all-drivers / USE=<driver> ...
		--with-drivers=all
		--enable-udev-rules
		--with-udev-rules-dir="$(get_udevdir)/rules.d"

		$(use_enable debug debug-log)
		$(use_enable static-libs static)
	)
	econf "${myeconfargs[@]}"
}

src_compile() {
	default

	use examples && emake -C examples
}

src_install() {
	default

	prune_libtool_files
}
