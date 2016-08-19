# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GH_URI="github/juhovh"
GH_REF="master@{${PV:0:4}-${PV:4:2}-${PV:6:2}}"

inherit autotools git-hosting eutils qmake-utils

DESCRIPTION="FOSS implementation of Apple AirPlay and RAOP protocol server"
LICENSE="MIT BSD LGPL-2.1+"

SLOT="0"

KEYWORDS="~amd64 ~arm"
IUSE="+ao gui"

CDEPEND="
	ao? ( >=media-libs/libao-1.1.0 )
	gui? (
		dev-qt/qtcore:4
		dev-qt/qtgui:4
		dev-qt/qtphonon:4
		dev-qt/qtmultimedia:4
		dev-qt/qtsvg:4
		dev-qt/qtsingleapplication[qt4]
	)"
DEPEND="${CDEPEND}
	dev-libs/libltdl"
RDEPEND="${CDEPEND}
	net-dns/avahi[mdnsresponder-compat]"

src_prepare() {
	default

	if ! use ao ; then
		sed -e '/PKG_CHECK_MODULES/ /libao/d' \
			-i -- configure.ac || die
	fi

	sed -e 's|-static-libtool-libs||' \
		-i -- src/Makefile.am || die

	# hardcode the path to airport.key instead of using a path relative to the working directory
	sed -e "s|airport.key|${EPREFIX}/etc/shairplay/airport.key|" \
		-i -- "${S}"/src/shairplay.c || die

	pushd "${S}/AirTV-Qt" >/dev/null || die
		# unbundle qtsingleapplication
		sed -e '/include(qtsingleapplication/d' -i -- AirTV.pro || die
		# link shared qtsingleapplication
		echo "CONFIG += qtsingleapplication" >> AirTV.pro || die
		# fix include path
		sed -e 's|../src/include|../include|' -i -- AirTV.pro || die
		# fix lib search path
		sed -e 's|\(-lshairplay\)|-L../src/lib/.libs/ \1|'  -i -- AirTV.pro || die

		# unused header from qt-multimedia-videowidget-example
		sed -e '/"videowidget.h"/d' -i -- main.cpp || die
	popd >/dev/null || die

	eautoreconf
	elibtoolize
}

src_configure() {
	default

	if use gui ; then
		pushd "${S}/AirTV-Qt" >/dev/null || die
		eqmake4 AirTV.pro
		popd >/dev/null || die
	fi
}

src_compile() {
	default

	use gui && emake -C "${S}/AirTV-Qt"
}

src_install() {
	default

	use gui && dobin AirTV-Qt/AirTV

	prune_libtool_files --all

	insinto /etc/shairplay
	doins airport.key
}
