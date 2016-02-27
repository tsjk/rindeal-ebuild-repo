# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

QT5_MODULE='qtbase' # base core dbus gui imageformats multimedia network widgets

inherit qmake-utils versionator eutils qt5-build

# prevent qttest from being assigned to DEPEND
E_DEPEND="${E_DEPEND/test? \( \~dev-qt\/qttest-* \)}"

DESCRIPTION="Patched Qt for net-im/telegram"
HOMEPAGE="https://github.com/telegramdesktop/tdesktop"

qt_ver="$( get_version_component_range 1-3 )"
qt_patch_rev='dd0c79ee5642695a39d5ff9d0e58e2f2b9f27534'
qt_patch_name="${P}-qtbase.patch"
# this path must be in sync with net-im/telegram ebuild
qt_prefix="${EROOT}opt/telegram-qt-static"

SRC_URI="
	https://download.qt-project.org/official_releases/qt/${qt_ver%.*}/${qt_ver}/single/qt-everywhere-opensource-src-${qt_ver}.tar.xz
	https://github.com/telegramdesktop/tdesktop/raw/${qt_patch_rev}/Telegram/_qtbase_${qt_ver//./_}_patch.diff -> ${qt_patch_name}
"

RESTRICT="strip test"
SLOT="0"
KEYWORDS="~amd64"
IUSE="alsa bindist gstreamer gstreamer010 gtkstyle libproxy pulseaudio systemd tslib"
REQUIRED_USE="?? ( gstreamer gstreamer010 )"

RDEPEND=(
	## BEGIN - QtCore
	'>=dev-libs/libpcre-8.35[pcre16]'
	'>=sys-libs/zlib-1.2.5'
	'virtual/libiconv'
	'dev-libs/glib:2'
	## END - QtCore

	## BEGIN - QtDbus
	'>=sys-apps/dbus-1.4.20'
	## END - QtDbus

	## BEGIN - QtGui
	'media-libs/fontconfig'
	'>=media-libs/freetype-2.5.5:2'
	'>=media-libs/harfbuzz-0.9.40:='
	'>=sys-libs/zlib-1.2.5'
	'gtkstyle? ('
		'x11-libs/gtk+:2'
		'x11-libs/pango'
		'!!x11-libs/cairo[qt4]'
	')'
	'virtual/jpeg:0'
	'media-libs/libpng:0='
	'tslib? ( x11-libs/tslib )'
		# BEGIN - QtGui - XCB
		'x11-libs/libICE'
		'x11-libs/libSM'
		'x11-libs/libX11'
		'>=x11-libs/libXi-1.7.4'
		'x11-libs/libXrender'
		'>=x11-libs/libxcb-1.10:=[xkb]'
		'>=x11-libs/libxkbcommon-0.4.1[X]'
		'x11-libs/xcb-util-image'
		'x11-libs/xcb-util-keysyms'
		'x11-libs/xcb-util-renderutil'
		'x11-libs/xcb-util-wm'
		# END - QtGui - XCB
	'systemd? ( sys-apps/systemd )'
	## END - QtGui

	## BEGIN - QtImageFormats
	'media-libs/jasper'
	'media-libs/libmng'
	'media-libs/libwebp'
	'media-libs/tiff:0'
	## END - QtImageFormats

	## BEGIN - QtMultimedia
	'alsa? ( media-libs/alsa-lib )'
	'gstreamer? ('
		'dev-libs/glib:2'
		'media-libs/gstreamer:1.0'
		'media-libs/gst-plugins-bad:1.0'
		'media-libs/gst-plugins-base:1.0'
	')'
	'gstreamer010? ('
		'dev-libs/glib:2'
		'media-libs/gstreamer:0.10'
		'media-libs/gst-plugins-bad:0.10'
		'media-libs/gst-plugins-base:0.10'
	')'
	'pulseaudio? ( media-sound/pulseaudio )'
	## END - QtMultimedia

	## BEGIN - QtNetwork
	'dev-libs/openssl:0[bindist=]'
	'>=sys-libs/zlib-1.2.5'
	'libproxy? ( net-libs/libproxy )'
	## END - QtNetwork
)
RDEPEND="${RDEPEND[@]}"
DEPEND=("${RDEPEND}"
	'virtual/pkgconfig'

	## BEGIN - QtMultimedia
	'gstreamer? ( x11-proto/videoproto )'
	## END - QtMultimedia
)
DEPEND="${DEPEND[@]}"
PDEPEND=">=net-im/telegram-0.9.24-r2
	app-i18n/ibus
"
QT5_TARGET_SUBDIRS=( )

S="${WORKDIR}/qt-everywhere-opensource-src-${qt_ver}"
QT5_BUILD_DIR="${S}"

src_unpack() {
	qt5-build_src_unpack

	# free some space
	cd "${S}" && rm -rf qt{webengine,webkit}
}

# override env to use our prefix and paths expected by tg sources
qt5_prepare_env() {
	# setup installation directories
	# note: keep paths in sync with qmake-utils.eclass
	QT5_PREFIX="${qt_prefix}"
	QT5_HEADERDIR="${QT5_PREFIX}/include"
	QT5_LIBDIR="${QT5_PREFIX}/lib"
	QT5_ARCHDATADIR="${QT5_PREFIX}"
	QT5_BINDIR="${QT5_ARCHDATADIR}/bin"
	QT5_PLUGINDIR="${QT5_ARCHDATADIR}/plugins"
	QT5_LIBEXECDIR="${QT5_ARCHDATADIR}/libexec"
	QT5_IMPORTDIR="${QT5_ARCHDATADIR}/imports"
	QT5_QMLDIR="${QT5_ARCHDATADIR}/qml"
	QT5_DATADIR="${QT5_PREFIX}/share"
	QT5_DOCDIR="${QT5_PREFIX}/share/doc/qt-${PV}"
	QT5_TRANSLATIONDIR="${QT5_DATADIR}/translations"
	QT5_EXAMPLESDIR="${QT5_DATADIR}/examples"
	QT5_TESTSDIR="${QT5_DATADIR}/tests"
	QT5_SYSCONFDIR="${EPREFIX}/etc/xdg"
	readonly QT5_PREFIX QT5_HEADERDIR QT5_LIBDIR QT5_ARCHDATADIR \
		QT5_BINDIR QT5_PLUGINDIR QT5_LIBEXECDIR QT5_IMPORTDIR \
		QT5_QMLDIR QT5_DATADIR QT5_DOCDIR QT5_TRANSLATIONDIR \
		QT5_EXAMPLESDIR QT5_TESTSDIR QT5_SYSCONFDIR

	# see mkspecs/features/qt_config.prf
	export QMAKEMODULES="${QT5_BUILD_DIR}/mkspecs/modules:${S}/mkspecs/modules:${QT5_ARCHDATADIR}/mkspecs/modules"
}

# unneeded
qt5_symlink_tools_to_build_dir() { true; }

src_prepare() {
	local qt_patch_file_lock="${T}/.qt_patched"
	if ! [ -f "${qt_patch_file_lock}" ]; then
		cd "${S}/qtbase"
		eapply "${DISTDIR}/${qt_patch_name}" && touch "${qt_patch_file_lock}"
	fi

	## BEGIN - QtGUI
	cd "${S}/qtbase"

	# avoid automagic dep on qtnetwork
	sed -i -e '/SUBDIRS += tuiotouch/d' \
		'src/plugins/generic/generic.pro' || die
	## END - QtGUI

	qt5-build_src_prepare
}

src_configure() {
	local myconf=(
		'-static'

		# use system libs
		'-system-'{freetype,harfbuzz,lib{jpeg,png},pcre,xcb,xkbcommon-x11,zlib}
		# enabled features
		-{fontconfig,glib,gui,iconv,icu,x{cb{,-xlib},input2,kb,render},widgets}
		-dbus # must not be `-linked` as it breaks build
		'-openssl-linked'

		# disabled features
		'-no-'{cups,directfb,eglfs,evdev,kms,libinput,linuxfb,mtdev,nis,opengl}

		# Telegram doesn't support sending files >4GB
		'-no-largefile'

		$(qt_use gtkstyle)
		$(qt_use libproxy)
		$(qt_use systemd journald)
		$(qt_use tslib)
	)
	use gstreamer	 && myconf+=( '-gstreamer' '1.0' )
	use gstreamer010 && myconf+=( '-gstreamer' '0.10' )

	qt5_base_configure
}

src_compile() {
	qt5-build_src_compile
	emake SHELL='sh -x' module-qt{base,imageformats}
}

src_install() {
	emake INSTALL_ROOT="${D}" module-qt{base,imageformats}-install_subtargets
}

# unneeded funcs
qt5-build_pkg_postinst() { true; }
qt5-build_pkg_postrm() { true; }
