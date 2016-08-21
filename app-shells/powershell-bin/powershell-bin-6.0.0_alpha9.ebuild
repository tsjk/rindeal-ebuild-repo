# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit unpacker

DESCRIPTION="Cross-platform automation and configuration tool/framework"
HOMEPAGE="https://github.com/PowerShell/PowerShell"
LICENSE="MIT"

# Gentoo:	`6.0.0_alpha9`
# Upstream:	`6.0.0-alpha.9`
[[ "${PV}" =~ ([0-9\.]+)(_([a-z]+)([0-9]+))? ]] || die "Version doesn't match"
MY_PV="${BASH_REMATCH[1]}"
[[ -n ${BASH_REMATCH[3]} ]] && MY_PV+="-${BASH_REMATCH[3]}"
[[ -n ${BASH_REMATCH[4]} ]] && MY_PV+=".${BASH_REMATCH[4]}"

SLOT="0"
SRC_URI="amd64? ( https://github.com/PowerShell/PowerShell/releases/download/v${MY_PV}/powershell_${MY_PV}-1ubuntu1.16.04.1_amd64.deb )"

KEYWORDS="-* ~amd64"

RDEPEND="
	dev-libs/icu:0/55
	sys-libs/libunwind"

RESTRICT+=" primaryuri strip test"

S="${WORKDIR}"

QA_TEXTRELS="opt/microsoft/powershell/*/libcoreclr.so"

src_install() {
	mkdir -v -p "${ED}"/opt/ || die
	cp -r --preserve=mode,timestamps opt/microsoft/ "${ED}"/opt/ || die
	mkdir -v -p "${ED}"/usr/bin/ || die
	ln -s "${EPREFIX}"/opt/microsoft/powershell/${MY_PV}/powershell "${ED}"/usr/bin/ || die

	dodoc usr/share/doc/powershell/changelog.gz
	doman usr/local/share/man/man1/powershell.1.gz
}
