# Copyright 1999-2014 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# git-hosting.eclass
GH_RN='github:alexkay'
[[ "${PV}" == *9999* ]] || GH_REF="v${PV}"
# wxwidgets.eclass
WX_GTK_VER="3.0"

inherit git-hosting
inherit autotools
inherit eutils
inherit toolchain-funcs
# functions: setup-wxwidgets
inherit wxwidgets
inherit xdg

DESCRIPTION="Analyse your audio files by showing their spectrogram"
HOMEPAGE="http://www.spek-project.org/ ${HOMEPAGE}"
LICENSE="GPL-3"

SLOT="0"

KEYWORDS="~amd64 ~arm"
IUSE="libav nls"

CDEPEND="
	libav? ( media-video/libav:= )
	!libav? ( media-video/ffmpeg:0= )

	x11-libs/wxGTK:${WX_GTK_VER}[X]
"
DEPEND="${CDEPEND}
	dev-util/intltool
	virtual/pkgconfig
	sys-devel/gettext
"
RDEPEND="${CDEPEND}"

pkg_setup() {
	setup-wxwidgets unicode
}

src_prepare() {
	if (( $(gcc-major-version) < 4 )) || \
		[[ (( $(gcc-major-version) == 4 )) && (( $(gcc-minor-version) < 7 )) ]]
	then
		die "You need to activate at least gcc:4.7"
	fi

	eapply "${FILESDIR}"/${PN}-0.8.3-replace-gnu+11-with-c++11.patch
	eapply_user

	eautoreconf
}

src_configure() {
	local myeconfargs=(
		$(use_enable nls)
	)
	econf "${myeconfargs[@]}"
}
