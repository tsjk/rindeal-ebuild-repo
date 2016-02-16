# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit multilib toolchain-funcs

DESCRIPTION="Hardware detection tool used in SuSE Linux"
HOMEPAGE="http://www.opensuse.org/"
LICENSE="GPL-2"
SRC_URI="https://github.com/openSUSE/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

SLOT="0"
KEYWORDS="~amd64 ~arm"
IUSE="doc"

DEPEND_COMMON="
	amd64? ( dev-libs/libx86emu )
	x86? ( dev-libs/libx86emu )
"
DEPEND="${DEPEND_COMMON}
	sys-devel/flex
	>=sys-kernel/linux-headers-2.6.17
	virtual/pkgconfig
	doc? ( app-doc/doxygen )
"
RDEPEND="${DEPEND_COMMON}
	dev-perl/XML-Parser
	virtual/udev
"

MAKEOPTS="${MAKEOPTS} -j1"

src_prepare() {
	default

	# Respect AR variable
	sed -i -e 's:ar r:$(AR) r:' src/{,isdn,ids,smp,hd}/Makefile || die

	# Respect LDFLAGS
	sed -i -e 's:$(CC) $(CFLAGS):$(CC) $(LDFLAGS) $(CFLAGS):' src/ids/Makefile || die

	# Respect MAKE variable
	sed -i 's:make:$(MAKE):' Makefile{,.common} || die

	# Skip forced -pipe and -g
	sed -i 's:-pipe -g::' Makefile.common || die
}

src_compile() {
	export HWINFO_VERSION=$PV

	emake CC="$(tc-getCC)" RPM_OPT_FLAGS="${CFLAGS}"
	use doc && emake doc
}

src_install() {
	emake DESTDIR="${ED}" LIBDIR="/usr/$(get_libdir)" install

	dodoc README*
	doman doc/*.{1,8}

	if use doc; then
		dodoc -r doc/libhd
		insinto /usr/share/doc/${PF}/examples
		doins doc/example*.c
	fi
}
