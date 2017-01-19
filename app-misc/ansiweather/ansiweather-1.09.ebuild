# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_URI='github/fcambus'

inherit git-hosting

DESCRIPTION='Weather in your terminal, with ANSI colors and Unicode symbols'
LICENSE='BSD'

SLOT='0'

KEYWORDS='~amd64 ~arm ~arm64'

RDEPEND="
	app-misc/jq:0
	net-misc/curl:0
	sys-devel/bc:0"

src_install() {
	dobin "${PN}"

	doman "${PN}.1"
	einstalldocs
	dodoc 'ansiweatherrc.example'
}
