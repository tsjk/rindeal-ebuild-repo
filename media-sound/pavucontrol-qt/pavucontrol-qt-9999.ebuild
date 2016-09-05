# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GH_URI="github/lxde"

inherit git-hosting cmake-utils

DESCRIPTION="Qt port of pavucontrol"
LICENSE="GPL-2"

SLOT="0"

[[ "${PV}" == *9999* ]] || KEYWORDS="~amd64 ~arm"
IUSE="doc"

CDEPEND="
	dev-libs/glib:2
	lxqt-base/liblxqt
	media-sound/pulseaudio[glib]
	dev-qt/qtdbus:5
	dev-qt/qtwidgets:5"
DEPEND="${CDEPEND}
	dev-qt/linguist-tools:5
	virtual/pkgconfig
	x11-misc/xdg-user-dirs"
RDEPEND="${CDEPEND}"

src_configure() {
	local mycmakeargs=(
		# workaround for missing cmake modules
		# TODO: remove this once lxqt-base/liblxqt>10.0 hits the tree
		-DCMAKE_MODULE_PATH="${FILESDIR}/cmake-find-modules"
	)
	cmake-utils_src_configure
}
