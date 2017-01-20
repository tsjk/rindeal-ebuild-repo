# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_URI="github/qbittorrent/qBittorrent"
GH_REF="release-${PV}"

# functions: append-cppflags
inherit flag-o-matic
# functions: eqmake(4|5)
inherit qmake-utils
inherit git-hosting
# EXPORT_FUNCTIONS: ...
inherit xdg
# functions: eautoreconf
inherit autotools
# functions: rindeal:expand_vars
inherit rindeal-utils
# functions: systemd_dounit
inherit systemd
# functions: multibuild_copy_sources
inherit multibuild

DESCRIPTION="BitTorrent client in C++/Qt based on libtorrent-rasterbar"
HOMEPAGE="https://www.qbittorrent.org/ ${GH_HOMEPAGE}"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE="+dbus debug nls +qt5 +gui webui"

CDEPEND_A=(
	"dev-libs/boost:="
	# libtorrent >= 1.1 is not yet officially supported, segfaults may occur
	# TODO: allow >= 1.1.2 after it's released
	"<net-libs/libtorrent-rasterbar-1.1:0"
	"sys-libs/zlib"

	"!qt5? ("
		"dev-libs/qjson[qt4(+)]"
		"dev-qt/qtcore:4[ssl]"
		"dev-qt/qtsingleapplication[qt4]"
		"gui? ("
			"dev-qt/qtgui:4"
			"dbus? ( dev-qt/qtdbus:4 )"
		")"
	")"
	"qt5? ("
		"dev-qt/qtconcurrent:5"
		"dev-qt/qtcore:5"
		"dev-qt/qtnetwork:5[ssl]"
		"dev-qt/qtxml:5"
		"gui? ("
			"dev-qt/qtgui:5"
			"dev-qt/qtwidgets:5"
			"dbus? ( dev-qt/qtdbus:5 )"
		")"
	")"
	"gui? ( dev-qt/qtsingleapplication[X] )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"qt5? ( nls? ( dev-qt/linguist-tools:5 ) )"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	"|| ( gui webui )"
)

inherit arrays

L10N_LOCALES=( ar be bg ca cs da de el en en_AU en_GB eo es eu fi fr gl he hi_IN hr hu hy id is it
	ja ka ko lt lv_LV ms_MY nb nl oc pl pt_BR pt_PT ro ru sk sl sr sv tr uk uz@Latn vi zh zh_HK zh_TW )
inherit l10n-r1

src_prepare() {
	xdg_src_prepare

	declare -g -r -a MULTIBUILD_VARIANTS=( $(usev gui) $(usev webui) )

	local l locales loc_dir='src/lang' loc_pre='qbittorrent_' loc_post='.ts'
	l10n_find_changes_in_dir "${loc_dir}" "${loc_pre}" "${loc_post}"
	l10n_get_locales locales app $(usex nls off all)
	for l in ${locales} ; do
		rm -vf "${loc_dir}/${loc_pre}${l}${loc_post}" || die
		sed -e "/qbittorrent_${l}.qm/d" -i -- src/lang.qrc || die
	done

	# make build verbose
	sed -r -e '/^CONFIG[ \+]*=/ s|silent||' -i -- src/src.pro || die

	# disable AUTOMAKE as no Makefile.am is present
	sed '/^AM_INIT_AUTOMAKE/d' -i -- configure.ac || die

	# disable qmake call inside ./configure script
	sed '/^$QT_QMAKE/ s|^|echo |' -i -- configure.ac || die

	eautoreconf

	multibuild_copy_sources
}

multibuild_src_configure() {
	# workaround build issue with older boost
	# https://github.com/qbittorrent/qBittorrent/issues/4112
	if has_version '<dev-libs/boost-1.58' ; then
		append-cppflags -DBOOST_NO_CXX11_REF_QUALIFIERS
	fi

	local econf_args=(
		--with-qjson=system
		--with-qtsingleapplication=system
		--disable-systemd # we have a service of our own

		$(use_enable dbus qt-dbus) # introduced for macOS
		$(use_enable debug)
		$(use_with !qt5 qt4)
	)

	if [[ "${MULTIBUILD_VARIANT}" == gui ]] ; then
		econf_args+=( --enable-gui --disable-webui )
	elif [[ "${MULTIBUILD_VARIANT}" == webui ]] ; then
		econf_args+=( --disable-gui --enable-webui )
	else
		die
	fi

	econf "${econf_args[@]}"

	eqmake$(usex qt5 5 4) -r ./qbittorrent.pro
}

src_configure() {
	multibuild_foreach_variant run_in_build_dir \
		multibuild_src_configure
}

src_compile() {
	multibuild_foreach_variant run_in_build_dir \
		default_src_compile
}

multibuild_src_install() {
	emake INSTALL_ROOT="${D}" install
}

src_install() {
	multibuild_foreach_variant run_in_build_dir \
		multibuild_src_install

	EXPAND_BINDIR="${EPREFIX}/usr/bin"
	if use webui ; then
		rindeal:expand_vars "${FILESDIR}/qbittorrent-nox@.service.in" "${T}/qbittorrent-nox@.service"
		rindeal:expand_vars "${FILESDIR}/qbittorrent-nox.user-service.in" "${T}/qbittorrent-nox.service"

		systemd_dounit "${T}/qbittorrent-nox@.service"
		systemd_douserunit "${T}/qbittorrent-nox.service"
	fi
	if use gui ; then
		rindeal:expand_vars "${FILESDIR}/qbittorrent.user-service.in" "${T}/qbittorrent.service"
		systemd_douserunit "${T}/qbittorrent.service"
	fi

	einstalldocs
}
