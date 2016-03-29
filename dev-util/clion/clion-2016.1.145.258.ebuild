# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils versionator fdo-mime

SLOT="2016.1"
PN_SLOTTED="${PN}${SLOT}"
MY_PV="$(get_version_component_range 1-2)"
BUILD_NUMBER="$(get_version_component_range 3-4)"

DESCRIPTION="A complete toolset for C and C++ development"
HOMEPAGE="https://www.jetbrains.com/clion"
LICENSE="IDEA || ( IDEA_Academic IDEA_Classroom IDEA_OpenSource IDEA_Personal )"
SRC_URI="http://download.jetbrains.com/cpp/CLion-${MY_PV}.tar.gz"

KEYWORDS="~amd64 ~x86 ~arm ~ppc"
RESTRICT="mirror strip"
IUSE="system-cmake system-gdb system-jre"

RDEPEND="
	system-cmake? ( >=dev-util/cmake-3.2 )
	system-gdb? ( >=sys-devel/gdb-7.8 )
	system-jre? ( >=virtual/jre-1.8 )"

S="${WORKDIR}/${PN}-${MY_PV}"

src_prepare() {
	default

	cd plugins/tfsIntegration/lib/native || die
	(
		shopt -s extglob
		eval "rm -rvf !(linux)"
	)
	cd linux || die
	use amd64	|| rm -rvf x86_64 || die
	use arm		|| rm -rvf arm "${S}/"bin/fsnotifier-arm || die
	use ppc		|| rm -rvf ppc || die
	use x86		|| rm -rvf x86 || die

	cd "${S}"
	if use system-cmake	; then rm -rvf bin/cmake license/CMake*	|| die ; fi
	if use system-gdb	; then rm -rvf bin/gdb license/GDB*		|| die ; fi
	if use system-jre	; then rm -rvf jre						|| die ; fi
}

src_install() {
	local install_dir="/opt/${PN_SLOTTED}"

	insinto "${install_dir}"
	doins -r *
	# globbing doesn't work with `fperms()`'
	chmod a+x "${D}/${install_dir}"/bin/${PN}.sh "${D}/${install_dir}"/bin/fsnotifier*
	use system-jre || chmod a+x "${D}/${install_dir}"/jre/jre/bin/*

	dosym "${install_dir}"/bin/${PN}.sh /usr/bin/${PN_SLOTTED}

	newicon -s 256 bin/${PN}.svg ${PN_SLOTTED}.svg

	make_desktop_entry_args=(
		"${PN_SLOTTED} %U"	# exec
		"CLion ${SLOT}"		# name
		"${PN_SLOTTED}"		# icon
		"Development;IDE"	# categories
	)
	make_desktop_entry_extras=( # MUST end with semicolon
		"MimeType=text/plain;text/x-c;text/x-h;"
	)
	make_desktop_entry "${make_desktop_entry_args[@]}" "$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"

	# recommended by: https://confluence.jetbrains.com/display/IDEADEV/Inotify+Watches+Limit
	mkdir -p "${D}"/etc/sysctl.d || die
	echo "fs.inotify.max_user_watches = 524288" > "${D}"/etc/sysctl.d/30-idea-inotify-watches.conf || die
}

pkg_postinst() {
	fdo-mime_desktop_database_update
}
