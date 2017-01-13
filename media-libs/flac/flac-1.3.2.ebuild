# Copyright 1999-2015 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools eutils

DESCRIPTION="Free lossless audio encoder and decoder"
HOMEPAGE="https://xiph.org/flac/"
LICENSE="BSD FDL-1.2 GPL-2 LGPL-2.1"

SLOT="0"
SRC_URI="http://downloads.xiph.org/releases/${PN}/${P}.tar.xz"

KEYWORDS="amd64 arm"
IUSE="altivec +cxx debug doc examples ogg cpu_flags_x86_sse static-libs"

RDEPEND="
	ogg? ( media-libs/libogg )"
DEPEND="${RDEPEND}
	app-arch/xz-utils
	sys-devel/gettext
	virtual/pkgconfig"

src_prepare() {
	local PATCHES=(
		"${FILESDIR}"/1.3.0-dont_build_tests.patch
		"${FILESDIR}"/1.3.2-configure_ac_flags.patch
		"${FILESDIR}"/1.3.2-LTLIBICONV.patch
		"${FILESDIR}"/1.3.2-honor_html_dir.patch
	)
	default

	use doc || sed -e '/SUBDIRS/ s|html||' -i -- doc/Makefile.am || die
	# https://sourceforge.net/p/flac/bugs/379/
	find doc/ -type f -name Makefile.am | xargs sed \
		-e 's|docdir = $(datadir)/doc/$(PACKAGE)-$(VERSION)|docdir = @docdir@|' -i --
	assert
	# delete doxygen tagfile
	sed -e 's|FLAC.tag||g' -e '/doc_DATA =/d' -i -- doc/Makefile.am || die

	use examples || sed -e '/^SUBDIRS/ s| examples | |' -i -- Makefile.am || die

	AT_M4DIR="m4" eautoreconf
}

src_configure() {
	local econf_args=(
		--docdir="${EPREFIX}"/usr/share/doc/${PF}
		--disable-doxygen-docs
		--disable-xmms-plugin
		--disable-thorough-tests

		$(use_enable altivec)
		$(use_enable cpu_flags_x86_sse sse)
		$(use_enable cxx cpplibs)
		$(use_enable debug)
		$(use_enable ogg)
	)
	econf "${econf_args[@]}"
}

src_test() {
	if [[ ${UID} != 0 ]]; then
		default
	else
		ewarn "Tests will fail if ran as root, skipping."
	fi
}

src_install() {
	default

	prune_libtool_files --all
}
