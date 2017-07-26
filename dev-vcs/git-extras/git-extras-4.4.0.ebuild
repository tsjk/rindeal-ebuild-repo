# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:tj"

# EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
# functions: dobashcomp
inherit bash-completion-r1

DESCRIPTION="GIT utilities -- repo summary, repl, changelog population and more"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( doc )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

src_compile() { :; }

src_install() {
	# NOTE: bashcompletion is broken for now
# 	newbashcomp etc/bash_completion.sh "${PN}"
	insinto /usr/share/zsh/site-functions
	newins etc/git-extras-completion.zsh "_${PN}"

	epushd bin
	for cmd in * ; do
		dobin "${cmd}"
# 		[[ "${cmd}" != "${PN}" ]] && \
# 			bashcomp_alias "${PN}" "${cmd}"
	done
	epopd

	doman man/*.1
}
