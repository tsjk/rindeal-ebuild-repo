# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# original work by stefan-gr (https://github.com/stefan-gr), the maintainer of abendbrot overlay

EAPI=6
inherit rindeal

GH_RN="github:cmdrkotori"

inherit git-hosting
# functions: eqmake5
inherit qmake-utils
# functions: make_desktop_entry
inherit eutils
inherit xdg

DESCRIPTION="Media Player Classic - Qute Theater; MPC-HC reimplemented using mpv/Qt"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64"

CDEPEND="
	>=media-video/mpv-0.18.0:0=[libmpv]
	dev-qt/qtx11extras:5
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtwidgets:5"
DEPEND="${CDEPEND}
	virtual/pkgconfig"
RDEPEND="${CDEPEND}"

src_configure() {
	eqmake5
}

src_install() {
	dobin mpc-qt

	newicon -s scalable "image-sources/logo.svg" "${PN}.svg"

	einstalldocs

	local make_desktop_entry_args=(
		"${EPREFIX}/usr/bin/${PN} -- %U"	# exec
		"Media Player Classic - Qute Theater"	# name
		"${PN}"	# icon
		'AudioVideo;Audio;Video;Player;TV;'	# categories
	)
	local make_desktop_entry_extras=(
		"MimeType=application/ogg;application/x-ogg;application/sdp;application/smil;application/x-smil;application/streamingmedia;application/x-streamingmedia;application/vnd.rn-realmedia;application/vnd.rn-realmedia-vbr;audio/aac;audio/x-aac;audio/m4a;audio/x-m4a;audio/mp1;audio/x-mp1;audio/mp2;audio/x-mp2;audio/mp3;audio/x-mp3;audio/mpeg;audio/x-mpeg;audio/mpegurl;audio/x-mpegurl;audio/mpg;audio/x-mpg;audio/rn-mpeg;audio/ogg;audio/scpls;audio/x-scpls;audio/vnd.rn-realaudio;audio/wav;audio/x-pn-windows-pcm;audio/x-realaudio;audio/x-pn-realaudio;audio/x-ms-wma;audio/x-pls;audio/x-wav;video/mpeg;video/x-mpeg;video/x-mpeg2;video/mp4;video/msvideo;video/x-msvideo;video/ogg;video/quicktime;video/vnd.rn-realvideo;video/x-ms-afs;video/x-ms-asf;video/x-ms-wmv;video/x-ms-wmx;video/x-ms-wvxvideo;video/x-avi;video/x-fli;video/x-flv;video/x-theora;video/x-matroska;video/webm;audio/x-flac;audio/x-vorbis+ogg;video/x-ogm+ogg;audio/x-shorten;audio/x-ape;audio/x-wavpack;audio/x-tta;audio/AMR;audio/ac3;video/mp2t;audio/flac;audio/mp4;"
	)
	make_desktop_entry "${make_desktop_entry_args[@]}" \
		"$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"
}
