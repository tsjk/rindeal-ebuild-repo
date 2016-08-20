# Copyright 1999-2015 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit xdg

DESCRIPTION="Pulseaudio Volume Control, GTK based mixer for Pulseaudio"
HOMEPAGE="https://freedesktop.org/software/pulseaudio/pavucontrol/"
LICENSE="GPL-2"

SLOT="0"
SRC_URI="${HOMEPAGE}/${P}.tar.xz"

KEYWORDS="~amd64"
IUSE="gtk3 nls"

CDEPEND="
	>=dev-libs/libsigc++-2.0:2
	>=media-sound/pulseaudio-3[glib]

	gtk3? (
		>=dev-cpp/gtkmm-2.99:3.0
		>=media-libs/libcanberra-0.16[gtk3]
	)
	!gtk3? (
		>=dev-cpp/gtkmm-2.16:2.4
		>=media-libs/libcanberra-0.16[gtk]
	)
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	nls? (
		dev-util/intltool
		sys-devel/gettext
	)
"
RDEPEND="${CDEPEND}
	virtual/freedesktop-icon-theme"

L10N_LOCALES=( as ru pt_BR uk nl de bn_IN es hu da or gu hi zh_CN el sr@latin kn fr sk pt mr cs tr pa th ca te sr ml fi pl ta sv ja it )
inherit l10n-r1

src_prepare-locales() {
	local l locales dir='po' pre='' post='.po'

	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"

	l10n_get_locales locales app off
	for l in ${locales} ; do
		rm -v -f "${dir}/${pre}${l}${post}" || die
		sed -e "/${l}/d" -i -- "${dir}"/LINGUAS || die
	done
}

src_prepare() {
	xdg_src_prepare

	src_prepare-locales

	# https://bugs.gentoo.org/show_bug.cgi?id=567216
	# https://cgit.freedesktop.org/pulseaudio/pavucontrol/commit/?id=4acb3ef0203647062b37b11e1d54700e3833c364
	# TODO: remove in >3.0
	sed -e '/AC_PROG_CXX/a AX_CXX_COMPILE_STDCXX_11' \
		-i -- configure.ac || die
}

src_configure() {
	local myeconfargs=(
		--disable-lynx	# Turn off lynx usage for documentation generation

		$(use_enable gtk3)
		$(use_enable nls)
	)
	econf "${myeconfargs[@]}"
}
