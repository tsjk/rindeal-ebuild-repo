# Copyright 1999-2016 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

inherit eutils
inherit flag-o-matic
inherit toolchain-funcs

DESCRIPTION="Lists open files for running Unix processes"
HOMEPAGE="https://people.freebsd.org/~abe/"
LICENSE="lsof"

MY_P=${P/-/_}
SLOT="0"
SRC_URI="https://www.mirrorservice.org/sites/lsof.itap.purdue.edu/pub/tools/unix/lsof/${MY_P}.tar.bz2
	ftp://lsof.itap.purdue.edu/pub/tools/unix/lsof/${MY_P}.tar.bz2"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE="examples ipv6 rpc selinux static"

RDEPEND="rpc? ( net-libs/libtirpc )
	selinux? ( sys-libs/libselinux )"
DEPEND="${RDEPEND}
	rpc? ( virtual/pkgconfig )"

S="${WORKDIR}/${MY_P}/${MY_P}_src"

src_unpack() {
	default

	cd "${MY_P}" || die
	unpack "./${MY_P}_src.tar"
}

src_prepare() {
	eapply "${FILESDIR}"/${PN}-4.85-cross.patch #432120
	eapply_user

	# fix POSIX compliance with `echo`
	sed -i \
		-e 's:echo -n:printf:' \
		AFSConfig Configure Customize Inventory tests/CkTestDB || die
	# Convert `test -r header.h` into a compile test.
	# Make sure we convert `test ... -a ...` into two `test` commands
	# so we can then convert both over into a compile test. #601432
	sed -i -E \
		-e '/if test .* -a /s: -a : \&\& test :g' \
		-e '/test -r/s:test -r \$\{LSOF_INCLUDE\}/([[:alnum:]/._]*):echo "#include <\1>" | ${LSOF_CC} ${LSOF_CFGF} -E - >/dev/null 2>\&1:g' \
		-e 's:grep (.*) \$\{LSOF_INCLUDE\}/([[:alnum:]/._]*):echo "#include <\2>" | ${LSOF_CC} ${LSOF_CFGF} -E -P -dD - 2>/dev/null | grep \1:' \
		Configure || die
}

src_configure() {
	use static && append-ldflags -static

	append-cppflags $(use rpc && $(tc-getPKG_CONFIG) libtirpc --cflags || echo "-DHASNOTRPC -DHASNORPC_H")
	append-cppflags $(usex ipv6 -{D,U}HASIPv6)

	export LSOF_CFGL="${CFLAGS} ${LDFLAGS} \
		$(use rpc && $(tc-getPKG_CONFIG) libtirpc --libs)"

	# Set LSOF_INCLUDE to a dummy location so the script doesn't poke
	# around in it and mix /usr/include paths with cross-compile/etc.
	touch .neverInv
	LINUX_HASSELINUX=$(usex selinux y n) \
	LSOF_INCLUDE=${T} \
	LSOF_CC=$(tc-getCC) \
	LSOF_AR="$(tc-getAR) rc" \
	LSOF_RANLIB=$(tc-getRANLIB) \
	LSOF_CFGF="${CFLAGS} ${CPPFLAGS}" \
	./Configure -n linux || die
}

src_compile() {
	emake DEBUG="" all
}

src_install() {
	dobin "${PN}"
	doman "${PN}.8"

	if use examples ; then
		insinto /usr/share/lsof/scripts
		doins scripts/*
	fi

	dodoc 00*
}
