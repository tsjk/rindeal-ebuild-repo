# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GH_URI='github/openSUSE'

inherit git-hosting multilib toolchain-funcs

DESCRIPTION='Hardware detection tool used in SuSE Linux'
LICENSE='GPL-2'

SLOT='0'

KEYWORDS='amd64 arm'

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

	local sed_args

	# Respect AR variable
	sed -e 's:ar r:$(AR) r:' \
		-i -- src/{,isdn,ids,smp,hd}/Makefile || die

	# Respect LDFLAGS
	sed -e 's:$(CC) $(CFLAGS):$(CC) $(LDFLAGS) $(CFLAGS):' \
		-i -- src/ids/Makefile || die

	# Respect MAKE variable
	sed -e 's:make:$(MAKE):' \
		-i -- Makefile{,.common} || die

	sed_args=(
		# Skip forced -pipe and -g
		-e 's:-pipe -g::'
		# respect CFLAGS
		-e 's|$(RPM_OPT_FLAGS)||g'
		# respect LD
		-e 's|LD[ \t]*=|LD ?=|'
	)
	sed  -i "${sed_args[@]}" \
		-- Makefile.common || die
}

src_configure() {
	export MAKEOPTS="${MAKEOPTS} -j1" HWINFO_VERSION="${PV}"
}

src_compile() {
	emake
	use doc && emake doc
}

src_install() {
	emake DESTDIR="${ED}" LIBDIR="${EPREFIX}/usr/$(get_libdir)" install

	dodoc README*
	doman doc/*.{1,8}

	use doc && dodoc -r doc/libhd
	if use examples ; then
		docinto examples
		dodoc doc/example*.c
	fi
}
