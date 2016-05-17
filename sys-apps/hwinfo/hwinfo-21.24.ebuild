# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GH_USER='openSUSE'

inherit github multilib toolchain-funcs

DESCRIPTION='Hardware detection tool used in SuSE Linux'
LICENSE='GPL-2'
SLOT='0'

KEYWORDS='~amd64 ~arm'
IUSE='doc examples'

CDEPEND="
	amd64? ( dev-libs/libx86emu )
	x86? ( dev-libs/libx86emu )
"
DEPEND="${CDEPEND}
	sys-devel/flex
	>=sys-kernel/linux-headers-2.6.17
	virtual/pkgconfig
	doc? ( app-doc/doxygen )
"
RDEPEND="${CDEPEND}
	dev-perl/XML-Parser
	virtual/udev
"

src_prepare() {
	default

	# Respect AR variable
	sed -i 's:ar r:$(AR) r:' -- src/{,isdn,ids,smp,hd}/Makefile || die

	# Respect LDFLAGS
	sed -i 's:$(CC) $(CFLAGS):$(CC) $(LDFLAGS) $(CFLAGS):' -- src/ids/Makefile || die

	# Respect MAKE variable
	sed -i 's:make:$(MAKE):' -- Makefile{,.common} || die

	# Skip forced -pipe and -g
	sed -i 's:-pipe -g::' -- Makefile.common || die

	export MAKEOPTS="${MAKEOPTS} -j1"
}

src_compile() {
	export HWINFO_VERSION=${PV}

	emake CC="$(tc-getCC)" RPM_OPT_FLAGS="${CFLAGS}"
	use doc && emake doc
}

src_install() {
	emake DESTDIR="${D}" LIBDIR="${ROOT}usr/$(get_libdir)" install

	dodoc README*
	doman doc/*.{1,8}

	if use doc; then
		dodoc -r doc/libhd
	fi
	if use examples; then
		docinto examples
		dodoc doc/example*.c
	fi
}
