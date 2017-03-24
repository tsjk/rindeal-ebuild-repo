# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_URI="github/hishamhm"

inherit autotools
# EXPORT_FUNCTIONS: pkg_setup
inherit linux-info
# EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
# EXPORT_FUNCTIONS: src_prepare, pkg_preinst, pkg_postinst, pkg_postrm
inherit xdg

DESCRIPTION="Interactive text-mode process viewer for Unix systems aiming to be a better top"
HOMEPAGE="https://hisham.hm/htop/ ${GH_HOMEPAGE}"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="amd64 arm ~arm64"
IUSE_A=( +cgroup hwloc +linux-affinity openvz unicode taskstats vserver )

CDEPEND_A=(
	"hwloc? ( sys-apps/hwloc )"
	"sys-libs/ncurses:0=[unicode?]"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	"?? ( hwloc linux-affinity )"
)

inherit arrays

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
	eapply "${FILESDIR}"/2.0.2-ncurses-tinfo.patch
	xdg_src_prepare

	# improve .desktop file (https://github.com/hishamhm/htop/pull/609)
	sed -e 's|\(Categories=\).*|\1System;Monitor;ConsoleOnly;|' \
		-i -- "${PN}.desktop" || die

	eautoreconf
}

src_configure() {
	local my_econf_args=(
		--enable-proc	# use Linux-compatible proc filesystem, disable only for non-Linux

		$(use_enable hwloc)				# enable hwloc support for CPU affinity
		$(use_enable linux-affinity)	# enable Linux sched_setaffinity and sched_getaffinity for affinity support, disables hwloc

		$(use_enable cgroup)
		$(use_enable openvz)
		$(use_enable taskstats)	# enable per-task IO Stats (taskstats kernel support required)
		$(use_enable unicode)
		$(use_enable vserver)
	)
	econf "${my_econf_args[@]}"
}

src_install() {
	default

	insinto /etc
	newins "${FILESDIR}"/2.0.2-htoprc htoprc

	doicon -s 128 ${PN}.png
}
