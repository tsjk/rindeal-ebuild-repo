# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools eutils qmake-utils xdg

DESCRIPTION="GTK+ UVC Viewer"
HOMEPAGE="http://guvcview.sourceforge.net/"
LICENSE="GPL-3"

MY_P="${PN}-src-${PV}"
SLOT="0"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"

KEYWORDS="~amd64"
IUSE="builtin-mjpg gsl libav nls pulseaudio qt5 +sdl2"

RDEPEND="
	media-libs/libpng:0=
	media-libs/libv4l
	>=media-libs/portaudio-19_pre
	virtual/ffmpeg
	virtual/libusb:1
	virtual/udev

	gsl? ( >=sci-libs/gsl-1.15 )
	!libav? ( >=media-video/ffmpeg-2.8:0= )
	libav? ( media-video/libav:= )
	qt5? ( dev-qt/qtwidgets:5 )
	!qt5? (
		>=x11-libs/gtk+-3.6:3
		>=dev-libs/glib-2.10
	)
	pulseaudio? ( >=media-sound/pulseaudio-0.9.15 )
	sdl2? ( media-libs/libsdl2 )
	!sdl2? ( >=media-libs/libsdl-1.2.10 )

	!<sys-kernel/linux-headers-3.4-r2" #448260
DEPEND="${RDEPEND}
	dev-util/intltool
	sys-devel/gettext
	virtual/os-headers
	sys-devel/autoconf-archive
	virtual/pkgconfig"

S="${WORKDIR}/${MY_P}"

L10N_LOCALES=( bg bs cs da de en_AU es eu fo fr gl he hr it ja lv nl pl pt pt_BR ru si sr tr uk zh_TW )
inherit l10n-r1

src_prepare-locales() {
	local l locales dir="po" pre="" post=".po"

	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"

	l10n_get_locales locales app off
	for l in ${locales} ; do
		rm -v -f "${dir}/${pre}${l}${post}" || die
		sed "/^ALL_LINGUAS/ s|${l}||" -i configure.ac || die
	done
}

src_prepare() {
	eapply "${FILESDIR}/ffmpeg3.patch"
	eapply_user

	src_prepare-locales

	# do not make some compiler prefered over another and let user make the choice
	sed -r 's:^AC_PROG_(CC|CXX).*:AC_PROG_\1:' -i configure.ac || die

	sed -i '/^docdir/,/^$/d' Makefile.am || die

	eautoreconf
}

src_configure() {
	export MOC="$(qt5_get_bindir)/moc"
	local myeconfargs=(
		--disable-debian-menu
		--disable-static
		$(use_enable builtin-mjpg)
		$(use_enable gsl)
		$(use_enable nls)
		$(use_enable pulseaudio pulse)
		$(use_enable qt5)
		$(use_enable !qt5 gtk3)
		$(use_enable sdl2)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	prune_libtool_files
}
