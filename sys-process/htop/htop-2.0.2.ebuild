# Copyright 1999-2016 Gentoo Foundation
#
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GH_URI="github/hishamhm"
# prevent clashes with 'hisham.hm' SRC_URI provider
GH_DISTFILE="${PN}-${PV}-github"

inherit autotools linux-info git-hosting

DESCRIPTION="Interactive text-mode process viewer for Unix systems aiming to be a better top"
HOMEPAGE="https://hisham.hm/htop/"
LICENSE="BSD GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm"
IUSE="+cgroup hwloc linux-affinity openvz unicode taskstats vserver"

RDEPEND="sys-libs/ncurses:0=[unicode?]"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

REQUIRED_USE="?? ( hwloc linux-affinity )"

pkg_setup() {
	if ! has_version sys-process/lsof ; then
		ewarn "To use lsof features in htop(what processes are accessing"
		ewarn "what files), you must have sys-process/lsof installed."
	fi

	CONFIG_CHECK="
		$(usex taskstats '~TASKSTATS' '')
		$(usex cgroup '~CGROUPS' '')"
	linux-info_pkg_setup
}

src_prepare() {
	PATCHES=(
		"${FILESDIR}/${PN}-2.0.2-tinfo.patch"
	)
	default

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

	doicon -s 128 ${PN}.png
}
