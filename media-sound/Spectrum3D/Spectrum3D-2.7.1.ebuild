# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# functions: eautoreconf
inherit autotools
# functions: doicon
inherit eutils

DESCRIPTION="Audio spectrum analyser in 3D"
HOMEPAGE="http://spectrum3d.sourceforge.net"
LICENSE="GPL-3"

MY_PN="${PN,,}"
MY_P="${MY_PN}-${PV}"
SLOT="0"
SRC_URI="mirror://sourceforge/${MY_PN}/${MY_P}.tar.gz"

KEYWORDS="~amd64"
IUSE="gtk3 gtkglext jack gstreamer010"

CDEPEND_A=(
	"gtk3? ( x11-libs/gtk+:3 )"
	"!gtk3? ("
		"x11-libs/gtk+:2"
		"gtkglext? ( x11-libs/gtkglext )"
	")"

	"!gtkglext? ( media-libs/libsdl )"

	# libGL, libGLU
	"virtual/opengl"

	# gstreamer-0.10
	"gstreamer010? ( media-libs/gstreamer:0.10 )"
	# gstreamer-1.0
	"!gstreamer010? ( media-libs/gstreamer:1.0 )"

	"jack? ( virtual/jack )"

	# libraries not packaged
# 	"geis? ("
# 		# libbamf
# 		"x11-libs/bamf"
# 		# libgeis
# 		"unity-base/geis"
# 	")"
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

REQUIRED_USE_A=(
	# gtkglext-3.0 (https://github.com/tdz/gtkglext) is not packaged yet
	"gtkglext? ( !gtk3 )"
)

inherit arrays

S="${WORKDIR}/${MY_P}"

src_prepare() {
	default

	# .desktop contains duplicated Type=
	gawk -i inplace '!seen[$0]++' "data/${MY_PN}.desktop.in" || die

	# missing includes
	#
	#     gstreamer.c:192:3: warning: implicit declaration of function 'g_sprintf'
	#
	sed -e '1 i\ #include <glib.h>\n#include <glib/gprintf.h>' -i -- src/gstreamer.c || die

	#
	#    events.c:224:5: warning: implicit declaration of function 'reset_view'
	#    events.c:228:5: warning: implicit declaration of function 'front_view'
	#
	# NOTE: including "main.h" won't work, because it includes too much causing conflicts
	sed -i '/#include "events.h"/ i\ void reset_view();\nvoid front_view();' src/events.c || die

	# fix icons path
	sed -e "s|icondir = .*|icondir = \$(datadir)/${PN}/icons|" -i -- data/Makefile.am || die
	grep --files-with-matches -r "g_build_filename.*.png" |\
		xargs \
		sed -r -e '/g_build_filename.*\.png/ '"s|\"icons\"|\"${PN}/icons\"|" -i --

	eautoreconf
}

src_configure() {
	local myeconfargs=(
		$(use_enable gtk3)
		$(use_enable '!gtk3' gtk2)
		$(use_enable gtkglext)
		$(use_enable jack)

	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	# 44x44
	doicon data/${MY_PN}.png
	doicon -s scalable data/${MY_PN}.svg
}
