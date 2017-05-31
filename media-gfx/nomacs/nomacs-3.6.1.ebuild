# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github"

inherit cmake-utils
inherit xdg
inherit git-hosting

DESCRIPTION="Qt-based image viewer"
HOMEPAGE="https://www.nomacs.org/ ${GH_HOMEPAGE}"
LICENSE="GPL-3+"

plugins_commit="be5886fab002d84963daab7820bd04f703e74b59" # 2017-03-23
SLOT="0"
git-hosting_gen_snapshot_url "github:${PN}:${PN}-plugins" "${plugins_commit}" plugins_snap_url plugins_snap_ext
SRC_URI+="
	plugins? ( ${plugins_snap_url} -> ${PN}-plugins-${PV}${plugins_snap_ext} )"

KEYWORDS="~amd64"
IUSE_A=( debug opencv +plugins raw tiff zip )

CDEPEND_A=(
	# qt deps specified in '${S}/cmake/Utils.cmake'
	"dev-qt/qtconcurrent:5"
	"dev-qt/qtcore:5"
	"dev-qt/qtgui:5"
	"dev-qt/qtnetwork:5"
	"dev-qt/qtprintsupport:5"
	"dev-qt/qtsvg:5"
	"dev-qt/qtwidgets:5"

	">=media-gfx/exiv2-0.25:="

	"opencv? ( >=media-libs/opencv-2.4.6:=[qt5] )"
	"raw? ( >=media-libs/libraw-0.17.0:= )"
	"tiff? ( media-libs/tiff:0 )"
	"zip? ( dev-libs/quazip[qt5] )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-qt/linguist-tools:5"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	"raw? ( opencv )"
	"tiff? ( opencv )"
)

inherit arrays

L10N_LOCALES=( ar ru uk nl de az hr es en ko fr bg sk pt sl zh cs bs sr pl als ja it )
inherit l10n-r1

S_OLD="${S}"
S="${S}/ImageLounge"

src_unpack() {
	git-hosting_src_unpack
	default

	[[ -d "${S}"/plugins ]] && die
	emv "${WORKDIR}"/*plugins* "${S}/plugins"
}

src_prepare-locales() {
	local l locales dir='translations' pre="${PN}_" post='.ts'

	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"

	l10n_get_locales locales app off
	for l in ${locales} ; do
		erm "${dir}/${pre}${l}${post}"
	done
}

src_prepare() {
	# prevent these from interfering with the build
	rm -r "${S_OLD}"/{LibRaw-*,exiv2-*,expat,installer,zlib-*} || die
	rm -r "${S}"/3rdparty/quazip-* || die

	sed -e 's|QStringList libPaths = QCoreApplication::libraryPaths();|QStringList libPaths;|' \
		-e "s|libPaths.append(QCoreApplication::applicationDirPath() + \"/plugins\");|libPaths.append(\"${EPREFIX}/usr/$(get_libdir)/nomacs-plugins\");|" \
		-i -- src/DkCore/DkPluginManager.cpp || die

	if use plugins ; then
		sed -e "s|DESTINATION lib/nomacs-plugins|DESTINATION $(get_libdir)/nomacs-plugins|" \
			-i -- plugins/cmake/Utils.cmake || die
	fi

	xdg_src_prepare
	cmake-utils_src_prepare

	src_prepare-locales
}

src_configure() {
	local mycmakeargs=(
		-D USE_SYSTEM_QUAZIP=ON
		# this app uses patched libqpsd + libqpsd is not in the tree
		# -D USE_SYSTEM_LIBQPSD=ON

		-D DISABLE_QT_DEBUG=$(usex debug)
		-D ENABLE_OPENCV=$(usex opencv)
		-D ENABLE_PLUGINS=$(usex plugins)
		-D ENABLE_RAW=$(usex raw)
		-D ENABLE_TIFF=$(usex tiff)
		# upnp support requires:
		# 	- fork herqq to a github/gitlab repo / use hupnp-ng
		# 		- because HUpnpAV is currently only in original SVN repo
		# 	- create a new herqq package which would use that fork/*-ng
		# 	- patch build system to use upnp on linux (-DWITH_UPNP)
		# 	- test everything works as probably no one used nomacs with upnp before
		#-D ENABLE_UPNP=$(usex upnp)
		-D ENABLE_QUAZIP=$(usex zip)
	)
	cmake-utils_src_configure
}
