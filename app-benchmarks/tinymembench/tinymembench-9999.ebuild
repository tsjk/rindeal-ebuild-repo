# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

DESCRIPTION="Simple benchmark for memory throughput and latency"
HOMEPAGE="https://github.com/ssvb/${PN}"
LICENSE="MIT"
EGIT_REPO_URI="https://github.com/ssvb/${PN}.git git://git@github.com:ssvb/${PN}.git"

inherit git-r3

SLOT="0"
KEYWORDS="~amd64 ~arm ~mips"
IUSE=""

src_install()
{
	dobin "$PN"
}
