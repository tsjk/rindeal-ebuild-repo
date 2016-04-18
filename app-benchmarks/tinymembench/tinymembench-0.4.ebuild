# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

GH_USER='ssvb'

inherit flag-o-matic github

DESCRIPTION="Simple benchmark for memory throughput and latency"
LICENSE="MIT"

SLOT="0"
KEYWORDS="~amd64 ~arm ~mips"

src_prepare() {
	# https://wiki.gentoo.org/wiki/Hardened/GNU_stack_quickstart
	append-flags '-Wa,--noexecstack'

	default
}

src_install() {
	dobin "$PN"
}
