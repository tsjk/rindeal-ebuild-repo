# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_URI="github/qbittorrent/qBittorrent"
GH_REF="release-${PV}"

# functions: append-cppflags
inherit flag-o-matic
# functions: eqmake*
inherit qmake-utils
# functions: eautoreconf
inherit autotools
inherit systemd
# EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
inherit xdg

DESCRIPTION="BitTorrent client in C++/Qt based on libtorrent-rasterbar"
HOMEPAGE="http://www.qbittorrent.org/ ${GH_HOMEPAGE}"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm"
IUSE_A=(dbus debug nls qt5 webui +X)

CDEPEND_A=(
	"dev-libs/boost:="
	# libtorrent >= 1.1 is not yet officially supported, segfaults may occur
	"<net-libs/libtorrent-rasterbar-1.1:0"
	"sys-libs/zlib"

	"!qt5? ("
		"dev-libs/qjson[qt4(+)]"
		"dev-qt/qtcore:4[ssl]"
		"dev-qt/qtsingleapplication[qt4,X?]"
		"X? ("
			"dev-qt/qtgui:4"
			"dbus? ( dev-qt/qtdbus:4 )"
		")"
	")"
	"qt5? ("
		"dev-qt/qtconcurrent:5"
		"dev-qt/qtcore:5"
		"dev-qt/qtnetwork:5[ssl]"
		"dev-qt/qtsingleapplication[qt5,X?]"
		"X? ("
			"dev-qt/qtgui:5"
			"dev-qt/qtxml:5"
			"dev-qt/qtwidgets:5"
			"dbus? ( dev-qt/qtdbus:5 )"
		")"
	")"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"qt5? ( nls? ( dev-qt/linguist-tools:5 ) )"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

L10N_LOCALES=( hy ar ru pt_BR uk nl nb gl de hr eu es hu da zh_TW pt_PT ka eo en el ro en_AU he ko fr bg
	sk be sl zh_HK zh hi_IN cs vi en_GB tr id lt ca sr fi pl sv ja it )
inherit l10n-r1

# the last time I tried a parallel build (2016-06; v3.3.4), it failed with:
# `g++: error: moc_transferlistfilterswidget.o: No such file or directory`
MAKEOPTS+=" -j1"

src_prepare() {
	eapply_user

	## locales
	local l locales loc_dir='src/lang' loc_pre='qbittorrent_' loc_post='.ts'
	l10n_find_changes_in_dir "${loc_dir}" "${loc_pre}" "${loc_post}"
	l10n_get_locales locales app $(usex nls off all)
	for l in ${locales} ; do
		rm -vf "${loc_dir}/${loc_pre}${l}${loc_post}" || die
		sed -e "/qbittorrent_${l}.qm/d" -i -- src/lang.qrc || die
	done

	# make build verbose
	sed -e '/CONFIG.*=/ s|silent||' \
		-i -- src/src.pro || die

	# disable AUTOMAKE as no Makefile.am is present
	sed -e '/^AM_INIT_AUTOMAKE/d' -i -- configure.ac || die

	# disable qmake call inside ./configure script, we'll call it manually later
	sed -e '/^$QT_QMAKE/ s|^|echo |' -i -- configure.ac || die

	eautoreconf
}

src_configure() {
	# workaround build issue with older boost
	# https://github.com/qbittorrent/qBittorrent/issues/4112
	if has_version '<dev-libs/boost-1.58' ; then
		append-cppflags -DBOOST_NO_CXX11_REF_QUALIFIERS
	fi

	local econf_args=(
		--with-qjson=system
		--with-qtsingleapplication=system
		# we're using a custom systemd service files
		--disable-systemd
		$(use_enable dbus qt-dbus)
		$(use_enable debug)
		$(use_enable webui)
		$(use_enable X gui)
		$(use_with !qt5 qt4)
	)
	econf "${econf_args[@]}"

	eqmake$(usex qt5 5 4) ./qbittorrent.pro
}

src_install() {
	emake INSTALL_ROOT="${D}" install

	systemd_newservice "${FILESDIR}/qbittorrent-nox@.service"
	systemd_newuserservice "${FILESDIR}/qbittorrent-nox@.service"

	einstalldocs
}
