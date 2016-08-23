# Copyright 2015-2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils
# xdg: src_prepare, pkg_preinst, pkg_postinst, pkg_postrm
inherit xdg

PN_PRETTY="SmartGit"
VN="syntevo"

DESCRIPTION="Git client with support for GitHub Pull Requests+Comments, SVN and Mercurial"
HOMEPAGE="https://www.syntevo.com/"${PN}""
LICENSE="smartgit"

SLOT="0"
SRC_URI="https://www.syntevo.com/static/smart/download/${PN}/${PN}-linux-${PV//./_}.tar.gz"

KEYWORDS="~amd64"

RDEPEND="
	>=virtual/jre-1.7
	|| ( dev-vcs/git dev-vcs/mercurial )
"

RESTRICT+=" mirror strip"

S="${WORKDIR}/${PN}"

src_install() {
	local install_dir="/opt/${VN}/${PN}"

	for s in 32 48 64 128 256 ; do
		newicon -s ${s} "bin/smartgit-${s}.png" "${PN}.png"
	done

	insinto "${install_dir}"
	doins -r .

	chmod -v a+x "${ED%/}${install_dir}/"{bin,lib}/*.sh || die

	dosym "${install_dir}/bin/smartgit.sh" "/usr/bin/${PN}"

	make_desktop_entry_args=(
		"${PN} %U"		# exec
		"${PN_PRETTY}"	# name
		"${PN}"			# icon
		"Development"	# categories
	)
	make_desktop_entry_extras=(
	)
	make_desktop_entry "${make_desktop_entry_args[@]}" \
		"$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"
}

pkg_postinst() {
	elog "${PN} relies on external git/hg executables to work."
	optfeature "Git support" dev-vcs/git
	optfeature "Mercurial support" dev-vcs/mercurial

	xdg_pkg_postinst
}
