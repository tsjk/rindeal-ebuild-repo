# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

inherit flag-o-matic-patched
inherit eutils

DESCRIPTION="Utility to change hard drive performance parameters"
HOMEPAGE="https://sourceforge.net/projects/${PN}/"
LICENSE="BSD GPL-2" # GPL-2 only

SLOT="0"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

KEYWORDS="~amd64 ~arm"
IUSE="static"

src_prepare() {
	PATCHES=(
		"${FILESDIR}"/9.28-wiper_sh_max_ranges.patch
		"${FILESDIR}"/9.43-fallocate_close_fd.patch
		"${FILESDIR}"/9.43-fix_zero_div_in_get_geom.patch
		"${FILESDIR}"/9.43-fix-bashisms.patch
		"${FILESDIR}"/9.48-fix_memleak_strdup.patch
		"${FILESDIR}"/9.48-sysmacros_header.patch
		"${FILESDIR}"/9.48-wiper_warn.patch
	)
	default

	local sed_args=(
		# no strip
		-e '/STRIP/d'
		# respect CC
		-e '/^CC/d'
		# respect CFLAGS
		-e "/^CFLAGS/ s|-O2||"
		# respect LDFLAGS
		-e "/^LDFLAGS/d"
	)
	sed "${sed_args[@]}" -i -- Makefile || die
}

src_configure() {
	use static && append-ldflags -static

	default
}

src_install() {
	DOCS=( hdparm.lsm Changelog README.acoustic hdparm-sysconfig )
	default

	doman "${PN}.8"

	# contrib/{idectl,ultrabayd} are terribly outdated, even debian doesn't install them
	insinto "/usr/share/${PN}/contrib"
	doins contrib/fix_standby*

	insinto "/usr/share/${PN}/wiper"
	doins -r wiper/*
}
