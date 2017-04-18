# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GH_RN='github:supercrabtree'

inherit git-hosting

DESCRIPTION='Directory listings for zsh with git features'
LICENSE='MIT'

SLOT='0'

KEYWORDS='~amd64 ~x86 ~arm'

RDEPEND="app-shells/zsh"

src_install() {
	insinto "usr/share/${PN}"
	doins 'k.sh'

	dodoc 'readme.md'
}
