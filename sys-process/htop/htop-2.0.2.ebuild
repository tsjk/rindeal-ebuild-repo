# Copyright 1999-2016 Gentoo Foundation
#
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GH_URI="github/hishamhm"

inherit autotools linux-info git-hosting

DESCRIPTION="Interactive text-mode process viewer for Unix systems aiming to be a better top"
HOMEPAGE="https://hisham.hm/htop/"
LICENSE="BSD GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm"
IUSE="+cgroup openvz unicode taskstats vserver"

RDEPEND="sys-libs/ncurses:0=[unicode?]"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

pkg_setup() {
	if ! has_version sys-process/lsof ; then
		ewarn "To use lsof features in htop(what processes are accessing"
		ewarn "what files), you must have sys-process/lsof installed."
	fi

	# TODO: check these
	CONFIG_CHECK="~TASKSTATS ~TASK_XACCT ~TASK_IO_ACCOUNTING ~CGROUPS"
	linux-info_pkg_setup
}

src_prepare() {
	PATCHES=(
		"${FILESDIR}/${PN}-2.0.2-tinfo.patch"
	)
	default

	#rm missing || die

	eautoreconf
}

src_configure() {
	local myeconfargs=(
		# fails to build against recent hwloc versions
		#--disable-hwloc
		--enable-hwloc
		--enable-proc	# use Linux-compatible proc filesystem

		$(use_enable cgroup)
		$(use_enable linux-affinity)
		$(use_enable openvz)
		$(use_enable taskstats)	# enable per-task IO Stats (taskstats kernel support required)
		$(use_enable unicode)
		$(use_enable vserver)
	)
	econf "${myeconfargs[@]}"
}
