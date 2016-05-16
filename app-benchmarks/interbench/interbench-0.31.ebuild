# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

DESCRIPTION="Con Kolivas' Benchmarking Suite -- Successor to Contest"
HOMEPAGE="http://users.tpg.com.au/ckolivas/interbench/"
LICENSE="GPL-2"

SLOT="0"
SRC_URI="http://ck.kolivas.org/apps/interbench/${P}.tar.bz2"

KEYWORDS="~amd64 ~arm ~x86"

src_prepare() {
	default

	# respect FLAGS
	sed -e 's|CFLAGS|#CFLAGS|' \
		-e 's|CC|#CC|' \
		-i -- Makefile || die

	# do not hardcode sched_priority (taken from FreeBSD Ports)
	sed -e 's|sched_priority = 99|sched_priority = sched_get_priority_max(SCHED_FIFO)|' \
		-e 's|set_fifo(96)|set_fifo(sched_get_priority_max(SCHED_FIFO) - 1)|' \
		-e 's|\(set_thread_fifo(thi->pthread,\) 95|\1 sched_get_priority_max(SCHED_FIFO) - 1|' \
		-i -- interbench.c || die

	# delete prebuilt binaries
	rm -vf *.o ${PN} || die
}

src_install() {
	dobin ${PN}
	doman ${PN}.8

	dodoc readme*
}

pkg_postinst() {
	einfo
	einfo "For best and consistent results, it is recommended to boot to init level 1 or"
	einfo "use telinit 1. See documentation or ${HOMEPAGE} for more info."
	einfo
}
