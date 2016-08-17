# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GH_URI="github/qbittorrent/qBittorrent"
GH_REF="release-${PV}"

inherit flag-o-matic qmake-utils git-hosting

DESCRIPTION="BitTorrent client in C++/Qt based on libtorrent-rasterbar"
HOMEPAGE="http://www.qbittorrent.org/ ${HOMEPAGE}"
LICENSE="GPL-2"

SLOT="0"
SRC_URI="https://sourceforge.net/projects/${PN}/files/${PN}/${P}/${P}.tar.xz/download -> ${P}.tar.xz"

KEYWORDS="~amd64 ~arm"
IUSE="+dbus debug +qt5 webui +X"

RDEPEND="
	dev-libs/boost:=
	net-libs/libtorrent-rasterbar:0
	sys-libs/zlib
	!qt5? (
		dev-libs/qjson[qt4(+)]
		dev-qt/qtcore:4[ssl]
		dev-qt/qtsingleapplication[qt4,X?]
		dbus? ( dev-qt/qtdbus:4 )
		X? ( dev-qt/qtgui:4 )
	)
	qt5? (
		dev-qt/qtconcurrent:5
		dev-qt/qtcore:5
		dev-qt/qtnetwork:5[ssl]
		dev-qt/qtsingleapplication[qt5,X?]
		dev-qt/qtxml:5
		dbus? ( dev-qt/qtdbus:5 )
		X? (
			dev-qt/qtgui:5
			dev-qt/qtwidgets:5
		)
	)
"
DEPEND="${RDEPEND}
	qt5? ( dev-qt/linguist-tools:5 )
	virtual/pkgconfig
"
REQUIRED_USE="
	dbus? ( X )
"

PLOCALES=( hy ar ru pt_BR uk nl nb gl de hr eu es hu da zh_TW pt_PT ka eo en el ro en_AU he ko fr bg
	sk be sl zh_HK zh hi_IN cs vi en_GB tr id lt ca sr fi pl sv ja it )
inherit l10n

# the last time I tried a parallel build (2016-06; v3.3.4), it failed with:
# `g++: error: moc_transferlistfilterswidget.o: No such file or directory`
MAKEOPTS+=" -j1"

src_prepare() {
	# make build verbose
	sed -r -e 's|(CONFIG .*)silent||' \
		-i -- src/src.pro || die

	local loc_dir='src/lang' loc_pre='qbittorrent_' loc_post='.ts'
	l10n_find_plocales_changes "${loc_dir}" "${loc_pre}" "${loc_post}"
	rm_loc() {
		rm -vf "${loc_dir}/${loc_pre}${1}${loc_post}" || die
		sed -e "/qbittorrent_${1}.qm/d" -i -- src/lang.qrc || die
	}
	l10n_for_each_disabled_locale_do rm_loc

	eapply_user
}

src_configure() {
	# workaround build issue with older boost
	# https://github.com/qbittorrent/qBittorrent/issues/4112
	if has_version '<dev-libs/boost-1.58'; then
		append-cppflags -DBOOST_NO_CXX11_REF_QUALIFIERS
	fi

	local econf_args=(
		--with-qjson=system
		--with-qtsingleapplication=system
		$(use_enable dbus qt-dbus)
		$(use_enable debug)
		$(use_enable webui)
		$(use_enable X gui)
		$(use_enable !X systemd) # Install the systemd service file (headless only).
		$(use_with !qt5 qt4)
	)
	econf "${econf_args[@]}"

	eqmake$(usex qt5 5 4)

	# disable stripping
	# TODO: find a way to do it in src_prepare()
	sed -e '/-$(STRIP)/d' -i -- 'src/Makefile' || die
}

src_install() {
	emake INSTALL_ROOT="${D}" install
	einstalldocs
}
