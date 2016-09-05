# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GH_URI="github/hishamhm"
# prevent clashes with 'hisham.hm' SRC_URI provider
GH_DISTFILE="${PN}-${PV}-github"

# linux-info: pkg_setup
# git-hosting: src_unpack
# xdg: src_prepare, pkg_preinst, pkg_postinst, pkg_postrm
inherit autotools linux-info git-hosting xdg

DESCRIPTION="Interactive text-mode process viewer for Unix systems aiming to be a better top"
HOMEPAGE="https://hisham.hm/htop/ ${HOMEPAGE}"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm"
IUSE="+cgroup hwloc +linux-affinity openvz unicode taskstats vserver"

RDEPEND="
	hwloc? ( sys-apps/hwloc )
	sys-libs/ncurses:0=[unicode?]"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

REQUIRED_USE="?? ( hwloc linux-affinity )"

pkg_setup() {
	if ! has_version sys-process/lsof ; then
		einfo "To use lsof features in htop (what processes are accessing"
		einfo "what files), you must have sys-process/lsof installed."
	fi
	if ! has_version dev-util/strace ; then
		einfo "To use strace features in htop (what processes are calling"
		einfo "what syscalls), you must have dev-util/strace installed."
	fi

	CONFIG_CHECK="
		$(usex taskstats '~TASKSTATS' '')
		$(usex cgroup '~CGROUPS' '')"
	linux-info_pkg_setup
}

src_prepare() {
	local PATCHES=(
		"${FILESDIR}"/2.0.2-ncurses-tinfo.patch )
	xdg_src_prepare

	# improve .desktop file
	sed -e 's|\(Categories=\).*|\1System;Monitor;ConsoleOnly;|' \
		-e 's|\(Keywords=\).*|\1system;process;task;|' \
		-i -- "${PN}.desktop" || die

	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--enable-proc	# use Linux-compatible proc filesystem, disable only for non-Linux

		$(use_enable hwloc)				# enable hwloc support for CPU affinity
		$(use_enable linux-affinity)	# enable Linux sched_setaffinity and sched_getaffinity for affinity support, disables hwloc

		$(use_enable cgroup)
		$(use_enable openvz)
		$(use_enable taskstats)	# enable per-task IO Stats (taskstats kernel support required)
		$(use_enable unicode)
		$(use_enable vserver)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	insinto /etc
	newins "${FILESDIR}"/2.0.2-htoprc htoprc

	doicon -s 128 ${PN}.png
}
