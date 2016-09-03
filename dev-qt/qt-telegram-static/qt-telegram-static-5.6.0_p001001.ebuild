# Copyright 2015-2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit versionator

{
	# 'module > subdir > package' bindings: https://wiki.gentoo.org/wiki/Project:Qt/Qt5status
	QT5_MODULE='qtbase'	# base ( core dbus gui network widgets ) imageformats
	QT_MODULES=( qtbase qtimageformats )	# list of qt modules used to generate SRC_URI

	inherit check-reqs eutils qmake-utils qt5-build

	# WARNING: this is a very dirty hack
	# prevent qttest from being assigned to DEPEND
	E_DEPEND="${E_DEPEND/test? \( \~dev-qt\/qttest-* \)}"
}
{
	QT_VER="$(get_version_component_range 1-3)"
	QT_PATCH_NUM="$(get_version_component_range 4 | tr -d 'p')"
	SLOT="${QT_VER}-${QT_PATCH_NUM}"
	# this path must be in sync with net-im/telegram-desktop ebuild
	QT5_PREFIX="${EPREFIX}/opt/${PN}/${QT_VER}/${QT_PATCH_NUM}"
	readonly QT_VER QT_PATCH_NUM SLOT QT5_PREFIX
}

DESCRIPTION='Patched Qt for net-im/telegram'
GH_REPO="telegramdesktop/tdesktop"
HOMEPAGE="https://github.com/${GH_REPO} https://www.qt.io"

# convert Qt patch number to a tag corresponding to a Telegram version
_qt_patch_tag="v$(( ${QT_PATCH_NUM:0:2} )).$(( ${QT_PATCH_NUM:2:2} )).$(( ${QT_PATCH_NUM:4:2} ))"
_qt_patch_uri_path="Telegram/Patches/qtbase_${QT_VER//./_}.diff"
QT_PATCH_LOCAL_NAME="${P}-qtbase.patch"

SRC_URI="https://github.com/${GH_REPO}/raw/${_qt_patch_tag}/${_qt_patch_uri_path} -> ${QT_PATCH_LOCAL_NAME}"
my_gen_qt_uris() {
	local m qt_submodules_base_uri="
		https://download.qt-project.org/official_releases/qt/${QT_VER%.*}/${QT_VER}/submodules"
	for m in "${QT_MODULES[@]}" ; do
		SRC_URI+="${qt_submodules_base_uri}/${m}-opensource-src-${QT_VER}.tar.xz"
	done
}
my_gen_qt_uris

KEYWORDS='~amd64 ~arm'
IUSE='bindist gtkstyle ibus +icu libinput libproxy systemd tslib'

RDEPEND_A=(
	## BEGIN - QtCore
	'dev-libs/glib:2'
	'>=dev-libs/libpcre-8.38[pcre16,unicode]'
	'>=sys-libs/zlib-1.2.5'
	'virtual/libiconv'
	'icu? ( dev-libs/icu )'
	'systemd? ( sys-apps/systemd )'
	## END - QtCore

	## BEGIN - QtDbus
	'>=sys-apps/dbus-1.4.20'
	## END - QtDbus

	## BEGIN - QtGui
	'dev-libs/glib:2'
	# '~dev-qt/qtcore-${PV}'
	'media-libs/fontconfig'
	'>=media-libs/freetype-2.6.1:2'
	'>=media-libs/harfbuzz-1.0.6:0'
	'>=sys-libs/zlib-1.2.5'
	'virtual/opengl'
	# 'dbus? ( ~dev-qt/qtdbus-${PV} )'
	# 'egl? ( media-libs/mesa[egl] )'
	# 'eglfs? ('
	# 	'media-libs/mesa[gbm]'
	# 	'x11-libs/libdrm'
	# ')'
	# 'evdev? ( sys-libs/mtdev )'
	'gtkstyle? ('
		'x11-libs/gtk+:2'
		'x11-libs/pango'
		'!!x11-libs/cairo[qt4]'
	')'
	# 'gles2? ( media-libs/mesa[gles2] )'
	'virtual/jpeg:0' # jpeg
	'libinput? ('
		'dev-libs/libinput:0'
		'x11-libs/libxkbcommon'
	')'
	'media-libs/libpng:0' # png
	'tslib? ( x11-libs/tslib )'
	# 'tuio? ( ~dev-qt/qtnetwork-${PV} )'
	# 'udev? ( virtual/libudev )'
		# BEGIN - QtGui - XCB
		'x11-libs/libICE'
		'x11-libs/libSM'
		'x11-libs/libX11'
		'>=x11-libs/libXi-1.7.4'
		'x11-libs/libXrender'
		'>=x11-libs/libxcb-1.10[xkb]'
		'>=x11-libs/libxkbcommon-0.4.1[X]'
		'x11-libs/xcb-util'-{image,keysyms,renderutil,wm}
		# END - QtGui - XCB
	## END - QtGui

	## BEGIN - QtImageFormats
	'media-libs'/{jasper,libmng,libwebp,tiff}':0'
	## END - QtImageFormats

	## BEGIN - QtNetwork
	'dev-libs/openssl:0[bindist=]'
	'>=sys-libs/zlib-1.2.5'
	'libproxy? ( net-libs/libproxy )'
	## END - QtNetwork
)
DEPEND_A=( "${RDEPEND_A[@]}"
	'virtual/pkgconfig'
)
PDEPEND_A=(
	# 'ibus? ( app-i18n/ibus )' # QtGui
)

inherit arrays

RESTRICT='test'

## !!! ORDER MATTERS !!!
## deps are in parentheses
QT5_TARGET_SUBDIRS=(
	## BEGIN - QtCore
	'qtbase/src/tools/'{bootstrap,moc,rcc}
	'qtbase/src/corelib'
	## END - QtCore

	## BEGIN - QtDbus (core)
	'qtbase/src/dbus'
	'qtbase/src/tools/qdbusxml2cpp' # Telegram doesn't use cpp2xml
	## END - QtDbus

	## BEGIN - QtNetwork (core, dbus)
	'qtbase/src/network'
	## END - QtNetwork

	## BEGIN - QtGui (core, dbus)
	'qtbase/src/'{gui,platform{headers,support}}
	'qtbase/src/plugins/'{generic,imageformats,platforms,platform{inputcontexts,themes}}
	## END - QtGui

	## BEGIN - QtImageFormats (core, gui)
	'qtimageformats'
	## END - QtImageFormats

	## BEGIN - QtWidgets (core, gui)
	'qtbase/src/tools/uic'
	'qtbase/src/widgets'
	## END - QtWidgets
)

QTBASE_PATCHES=(
	"${FILESDIR}"/qtdbus-5.6.0-deadlock.patch
	"${FILESDIR}"/qtcore-5.5.1-libsystemd.patch )

# size varies between 400M-1100M depending on compiler flags
CHECKREQS_DISK_BUILD='800M'

S="${WORKDIR}"
QT5_BUILD_DIR="${S}"
QTBASE_DIR="${S}/qtbase"

pkg_setup() {
	echo
	einfo "${PN} is going to be installed into '${QT5_PREFIX}'"
	echo
}

src_unpack() {
	qt5-build_src_unpack

	## rename dirs according to the module they contain
	local m
	for m in ${QT_MODULES[@]} ; do
		mv -v "${m}-opensource-src-${QT_VER}" "${m}" || die
	done
}

# override env to use our prefix and paths expected by tg sources
qt5_prepare_env() {
	QT5_HEADERDIR="${QT5_PREFIX}/include"
	QT5_LIBDIR="${QT5_PREFIX}/lib"
	QT5_ARCHDATADIR="${QT5_PREFIX}"
	QT5_BINDIR="${QT5_ARCHDATADIR}/bin"
	QT5_PLUGINDIR="${QT5_ARCHDATADIR}/plugins"
	QT5_LIBEXECDIR="${QT5_ARCHDATADIR}/libexec"
	QT5_IMPORTDIR="${QT5_ARCHDATADIR}/imports"
	QT5_QMLDIR="${QT5_ARCHDATADIR}/qml"
	QT5_DATADIR="${QT5_PREFIX}/share"
	QT5_DOCDIR="${QT5_PREFIX}/share/doc/qt-${QT_VER}"
	QT5_TRANSLATIONDIR="${QT5_DATADIR}/translations"
	QT5_EXAMPLESDIR="${QT5_DATADIR}/examples"
	QT5_TESTSDIR="${QT5_DATADIR}/tests"
	QT5_SYSCONFDIR="${EPREFIX}/etc/xdg"
	readonly QT5_PREFIX QT5_HEADERDIR QT5_LIBDIR QT5_ARCHDATADIR QT5_BINDIR QT5_PLUGINDIR \
		QT5_LIBEXECDIR QT5_IMPORTDIR QT5_QMLDIR QT5_DATADIR QT5_DOCDIR QT5_TRANSLATIONDIR \
		QT5_EXAMPLESDIR QT5_TESTSDIR QT5_SYSCONFDIR

	# WARNING: this is very dangerous to change, if you put QT5_ARCHDATADIR here,
	# the installation will result into a spaghetti mix up.
	# See: mkspecs/features/qt_config.prf
	export QMAKEMODULES="${QT5_BUILD_DIR}/mkspecs/modules:${S}/mkspecs/modules"
}

src_prepare() {
	cd "${QTBASE_DIR}" || die

	eapply "${DISTDIR}/${QT_PATCH_LOCAL_NAME}" # this bitch is why this ebuild exists

	(( ${#QTBASE_PATCHES[@]} )) && eapply "${QTBASE_PATCHES[@]}"

	# apply user patches now, because qt5-build_src_prepare() calls default() in a wrong dir
	pushd "${S}" >/dev/null || die
	eapply_user
	popd >/dev/null || die

	## BEGIN - QtGui
	# avoid automagic dep on qtnetwork
	sed -e '/SUBDIRS += tuiotouch/d' \
		-i -- 'src/plugins/generic/generic.pro' || die
	## END - QtGui

	qt5-build_src_prepare
}

# not using this feature
qt5_symlink_tools_to_build_dir() { : ; }

## customized qt5-build_src_configure()
src_configure() {
	local myconf=(
		-static

		# use system libs
		-system-{freetype,harfbuzz,libjpeg,libpng,pcre,xcb,xkbcommon-x11,zlib}

		## enabled features
		-{fontconfig,gui,iconv,xcb,xcb-xlib,xinput2,xkb,xrender,widgets}
		-{dbus,openssl}-linked
		## disabled features
		-no-{glib,nis,qml-debug}
		-no-largefile # Telegram doesn't support sending files >4GB

		$(usex amd64 -reduce-relocations '') # buggy on other arches

		$(qt_use gtkstyle)
		$(qt_use icu)
		$(qt_use libinput)
		$(qt_use libproxy)
		$(qt_use systemd journald)
		$(qt_use tslib)
	)

	# This configure will build qmake for use in builds of other modules.
	# The global qmake will not work.
	S="${QTBASE_DIR}" QT5_BUILD_DIR="${QTBASE_DIR}" \
		qt5_base_configure

	# The following round of qmakes will output some warning messages, which look like this:
	#
	#     .../qtbase/bin/<TOOL>: not found
	#
	# Just ignore them, they're harmless.
	my_qt5_qmake() {
		# this ensures that correct qmake will be called
		local QT5_MODULE= QT5_BINDIR="${QTBASE_DIR}/bin"
		qt5_qmake
	}
	qt5_foreach_target_subdir \
		my_qt5_qmake
}

## customized qt5-build_src_install()
src_install() {
	qt5_foreach_target_subdir \
		emake INSTALL_ROOT="${D}" install

	emake -C "${QTBASE_DIR}" INSTALL_ROOT="${D}" install_{qmake,mkspecs}

	prune_libtool_files

	# fix .prl files
	local sed_args=(
		# - Drop QMAKE_PRL_BUILD_DIR because it references the build dir
		-e '/^QMAKE_PRL_BUILD_DIR/d'
		# - Fix -L paths referencing build dir
		-e "s|-L${S}[^ ]*||g"
	)
	find "${D}" -type f -name '*.prl' | xargs sed "${sed_args[@]}" -i --
	assert
}

# unneeded funcs
qt5-build_pkg_postinst() { : ; }
qt5-build_pkg_postrm() { : ; }
