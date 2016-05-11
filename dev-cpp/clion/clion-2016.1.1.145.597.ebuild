# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils versionator fdo-mime

SLOT="2016.1"
PN_SLOTTED="${PN}${SLOT}"
if [ $(get_version_component_range 3) -eq 0 ] ;then
	MY_PV="$(get_version_component_range 1-2)"
else
	MY_PV="$(get_version_component_range 1-3)"
fi
BUILD_NUMBER="$(get_version_component_range 4-5)"

DESCRIPTION="A complete toolset for C and C++ development"
HOMEPAGE="https://www.jetbrains.com/clion"
LICENSE="IDEA || ( IDEA_Academic IDEA_Classroom IDEA_OpenSource IDEA_Personal )"
SRC_URI="http://download.jetbrains.com/cpp/CLion-${MY_PV}.tar.gz"

KEYWORDS="~amd64 ~x86"
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
	rm -rvf ppc || die
	use amd64	|| rm -rvf x86_64 || die
	use x86		|| rm -rvf x86 || die
	use arm		|| rm -rvf arm "${S}/"bin/fsnotifier-arm || die

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
	chmod a+x "${D}/${install_dir}"/bin/${PN}.sh "${D}/${install_dir}"/bin/fsnotifier* || die
	use system-cmake	|| chmod a+x "${D}/${install_dir}"/bin/cmake/bin/*	|| die
	use system-gdb		|| chmod a+x "${D}/${install_dir}"/bin/gdb/bin/*	|| die
	use system-jre		|| chmod a+x "${D}/${install_dir}"/jre/jre/bin/*	|| die

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
		"StartupWMClass=jetbrains-clion"
	)
	make_desktop_entry "${make_desktop_entry_args[@]}" "$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"

	# recommended by: https://confluence.jetbrains.com/display/IDEADEV/Inotify+Watches+Limit
	mkdir -p "${D}"/etc/sysctl.d || die
	echo "fs.inotify.max_user_watches = 524288" > "${D}"/etc/sysctl.d/30-idea-inotify-watches.conf || die
}

pkg_postinst() {
	fdo-mime_desktop_database_update
}
