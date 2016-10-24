# Copyright 1999-2015 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
inherit rindeal

inherit flag-o-matic toolchain-funcs

DESCRIPTION="POSIX compliant shell, a direct descendant of the NetBSD version of ash"
HOMEPAGE="http://gondor.apana.org.au/~herbert/dash/"
LICENSE="BSD"

SLOT="0"
SRC_URI="http://gondor.apana.org.au/~herbert/${PN}/files/${P}.tar.gz"

KEYWORDS="~amd64 ~arm"
IUSE="+fnmatch libedit static"

RDEPEND="!static? ( libedit? ( dev-libs/libedit ) )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	libedit? ( static? ( dev-libs/libedit[static-libs] ) )"

src_prepare() {
	PATCHES=(
		"${FILESDIR}"/0.5.9.1-dumb_echo.patch
		"${FILESDIR}"/0.5.8-SHELL-print-n-upon-EOF-CTRL-D-when-run-interactively.patch
		"${FILESDIR}"/0.5.8-PARSER-Remove-backslash-before-in-double-quotes-in-va.patch
		"${FILESDIR}"/0.5.8-SHELL-Disable-sh-c-command-sh-c-exec-command-optimization.patch
		"${FILESDIR}"/0.5.8-JOBS-address-format-security-build-error.patch
		"${FILESDIR}"/0.5.8-EVAL-Report-I-O-error-on-stdout.patch )
	default

	# Fix the invalid sort
	sed -e 's|LC_COLLATE=C|LC_ALL=C|g' -i -- src/mkbuiltins || die

	# Use pkg-config for libedit linkage
	sed -e "/LIBS/s|-ledit|\`$(tc-getPKG_CONFIG) --libs libedit $(usex static --static '')\`|" \
		-i -- configure || die
}

src_configure() {
	append-cppflags -DJOBS=$(usex libedit 1 0) # FIXME

	local econf_args=(
		--bindir="${EPREFIX}"/bin
		# Do not pass --enable-glob due to #443552.
		--disable-glob
		# Autotools use $LINENO as a proxy for extended debug support
		# (i.e. they're running bash), so disable that. #527644
		--disable-lineno

		$(use_enable fnmatch)
		$(use_with libedit)
		$(use_enable static)
	)
	econf "${econf_args[@]}"
}
