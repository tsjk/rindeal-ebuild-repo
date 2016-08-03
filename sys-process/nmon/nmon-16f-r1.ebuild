# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit flag-o-matic toolchain-funcs

MY_P="lmon${PV}"

DESCRIPTION="Nigel's performance MONitor for CPU, memory, network, disks, etc..."
HOMEPAGE="http://nmon.sourceforge.net/"
LICENSE="GPL-3"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.c"

SLOT="0"
KEYWORDS="amd64 arm"

RDEPEND="sys-libs/ncurses:0="
DEPEND="${RDEPEND}
	sys-apps/help2man
	virtual/pkgconfig
"

S="${WORKDIR}"

src_unpack() {
	cp -v -f "${DISTDIR}"/${MY_P}.c "${S}"/${PN}.c || die
}

src_configure() {
	local cflags=(
		## recommended by upstream to be always on
		-DGETUSER
		-DJFS
		-DKERNEL_2_6_18
		-DLARGEMEM

		## archs
		$(usex amd64 -DX86 '')
		$(usex arm -DARM '')
	)
	append-cflags "${cflags[@]}"
	export LDLIBS="$( $(tc-getPKG_CONFIG) --libs ncurses ) -lm"
}

src_compile() {
	emake ${PN}

	local help2man=(
		help2man

		--help-option=-h
		--no-info
		--no-discard-stderr
		--name="Performance Monitor"
		--version-string=${PV}

		./${PN}
	)
	"${help2man[@]}" > ${PN}.1
}

src_install() {
	dobin ${PN}
	doman ${PN}.1

	newenvd "${FILESDIR}"/${PN}.envd 70${PN}
}
