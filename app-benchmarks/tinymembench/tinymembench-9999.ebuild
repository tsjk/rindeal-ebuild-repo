# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit git-r3

DESCRIPTION="Simple benchmark for memory throughput and latency"
HOMEPAGE="https://github.com/ssvb/tinymembench"
LICENSE="MIT"
EGIT_REPO_URI="https://github.com/ssvb/tinymembench.git"

SLOT="0"
KEYWORDS="~amd64 ~arm ~mips"

src_install() {
	dobin "$PN"
}
