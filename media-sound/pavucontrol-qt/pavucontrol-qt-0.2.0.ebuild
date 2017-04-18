# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:lxde"

inherit git-hosting
inherit cmake-utils

DESCRIPTION="Qt port of pavucontrol"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64"
IUSE="doc"

CDEPEND_A=(
	"dev-libs/glib:2"
	">=lxqt-base/liblxqt-0.10"
	"media-sound/pulseaudio[glib]"
	"dev-qt/qtdbus:5"
	"dev-qt/qtwidgets:5"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	">=dev-util/lxqt-build-tools-${PV}"
	"dev-qt/linguist-tools:5"
	"virtual/pkgconfig"
	"x11-misc/xdg-user-dirs"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

src_prepare() {
	default

	# https://github.com/lxde/pavucontrol-qt/issues/31
	sed -e 's|"changes-prevent"|"changes-prevent-symbolic"|' -i src/*.ui || die

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		# prevent lxqt-build-tools from pulling translations from a remote git server
		-D PULL_TRANSLATIONS=''
	)

	cmake-utils_src_configure
}
