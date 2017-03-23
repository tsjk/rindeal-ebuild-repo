# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# functions: eautoreconf
inherit autotools
# functions: doicon
inherit eutils

DESCRIPTION="Audio spectrum analyser in 3D"
HOMEPAGE="http://spectrum3d.sourceforge.net https://sourceforge.net/projects/spectrum3d/"
LICENSE="GPL-3"

SLOT="0"
MY_PN="${PN,,}"
MY_P="${MY_PN}-${PV}"
SRC_URI="mirror://sourceforge/${MY_PN}/${MY_P}.tar.gz"

KEYWORDS="~amd64"
IUSE="gtk3 sdl jack gstreamer010"

CDEPEND_A=(
	"gtk3? ( x11-libs/gtk+:3 )"
	"!gtk3? ( x11-libs/gtk+:2 )"

	"sdl? ( media-libs/libsdl )"
	"!sdl? ( media-libs/libsdl2 )"

	# libGL, libGLU
	"virtual/opengl"

	# gstreamer-0.10
	"gstreamer010? ( media-libs/gstreamer:0.10 )"
	# gstreamer-1.0
	"!gstreamer010? ( media-libs/gstreamer:1.0 )"

	"jack? ( virtual/jack )"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	# equalizer-nbands, audiochebband, jackaudiosrc, spectrum, wavenc, jackaudiosink, autoaudiosink
	"gstreamer010? ( media-libs/gst-plugins-good:0.10 )"
	"!gstreamer010? ( media-libs/gst-plugins-good:1.0 )"
	# alsasrcm, playbin, audioconvert, audiotestsrc
	"gstreamer010? ( media-libs/gst-plugins-base:0.10 )"
	"!gstreamer010? ( media-libs/gst-plugins-base:1.0 )"
)

inherit arrays

S="${WORKDIR}/${MY_P}"

src_prepare() {
	default

	# .desktop contains duplicated Type= (https://sourceforge.net/p/spectrum3d/discussion/bug-wishlist/thread/d429f757/)
	gawk -i inplace '!seen[$0]++' "data/${MY_PN}.desktop.in" || die

	## fix icons path (https://sourceforge.net/p/spectrum3d/discussion/bug-wishlist/thread/8c685767/)
	# the svg icon is used only in the desktop menu entry
	sed -r -e "s|^(svgicondir =).*|\1 \$(datadir)/icons/hicolor/scalable/apps|" -i -- data/Makefile.am || die

	sed -e "1s|^|icondir = \$(datadir)/${PN}/icons\n|" -i -- src/Makefile.am || die
	sed -r -e "s|^(icondir =).*|\1 \$(datadir)/${PN}/icons|" -i -- data/Makefile.am || die
	# pass $(icondir) to source files
	sed -e "/^AM_CPPFLAGS =/ s|$| -D ICONDIR='\"\$(icondir)\"'|" -i -- src/Makefile.am || die
	grep --files-with-matches -r "g_build_filename.*DATADIR.*icons" |\
		xargs \
		sed -r -e '/g_build_filename.*DATADIR.*icons/ '"s|DATADIR, \"icons\"|ICONDIR|" -i --

	eautoreconf
}

src_configure() {
	local myeconfargs=(
		$(use_enable gtk3)
		$(use_enable '!gtk3' gtk2)
		$(use_enable sdl)
		$(use_enable '!sdl' sdl2)
		$(use_enable jack)

	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	# 44x44
	doicon data/${MY_PN}.png
}
