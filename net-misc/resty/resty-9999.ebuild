# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

GH_USER='micha'

inherit github

DESCRIPTION='Little command line REST client that you can use in pipelines (bash or zsh)'
LICENSE='MIT'

SLOT='0'

KEYWORDS='~amd64 ~x86 ~arm'

CDEPEND_A=( )
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

DEPEND="${DEPEND_A[*]}"
RDEPEND="${RDEPEND_A[*]}"

# opt: lynx/html2text for pretty printing

src_install() {
	insinto "/usr/share/${PN}"
	doins "${PN}"

	local DOCS=( 'CHANGES.md' 'README.md' )
	einstalldocs
}
