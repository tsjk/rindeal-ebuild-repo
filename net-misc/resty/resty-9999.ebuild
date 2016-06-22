# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GH_URI='github/micha'

inherit git-hosting

DESCRIPTION='Little command line REST client that you can use in pipelines (bash or zsh)'
LICENSE='MIT'

SLOT='0'

KEYWORDS='~amd64 ~x86 ~arm'

# opt: lynx/html2text for pretty printing

src_install() {
	insinto "/usr/share/${PN}"
	doins "${PN}"

	local DOCS=( CHANGES.md README.md )
	einstalldocs
}
