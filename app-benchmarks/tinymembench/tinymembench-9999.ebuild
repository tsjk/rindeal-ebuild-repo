# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

GH_USER='ssvb'

inherit github

DESCRIPTION="Simple benchmark for memory throughput and latency"
LICENSE="MIT"

SLOT="0"
KEYWORDS="~amd64 ~arm ~mips"

src_install() {
	dobin "$PN"
}
