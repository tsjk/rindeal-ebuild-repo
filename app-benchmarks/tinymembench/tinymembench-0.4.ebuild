# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN='github:ssvb'
GH_REF="v${PV}"

inherit flag-o-matic
inherit git-hosting

DESCRIPTION="Simple benchmark for memory throughput and latency"
LICENSE="MIT"

SLOT="0"

KEYWORDS="amd64 arm ~arm64"

src_prepare() {
	# https://wiki.gentoo.org/wiki/Hardened/GNU_stack_quickstart
	append-flags '-Wa,--noexecstack'

	default
}

src_install() {
	dobin "${PN}"
}
