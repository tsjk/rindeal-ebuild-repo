# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2
# $Id$

# upstream guide: https://developer.mozilla.org/en-US/docs/Mozilla/Developer_guide/Build_Instructions

EAPI=6

PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE='ncurses,sqlite,ssl,threads'

# will resolve to 2.13, newer don't work (https://bugzilla.mozilla.org/show_bug.cgi?id=104642)
WANT_AUTOCONF="2.1"

inherit firefox autotools check-reqs flag-o-matic python-any-r1

DESCRIPTION="Firefox Web Browser (rindeal's edition)"
HOMEPAGE='https://www.mozilla.com/firefox'
LICENSE='MPL-2.0 GPL-2 LGPL-2.1'

ESR=true # comment out to disable
MOZ_PV="${PV}${ESR:+"esr"}"
MOZ_P="${PN}-${MOZ_PV}"

SLOT='0'
SRC_URI="https://archive.mozilla.org/pub/firefox/releases/${MOZ_PV}/source/${MOZ_P}.source.tar.xz"

KEYWORDS='~amd64 ~arm ~arm64 ~x86'
IUSE_A=(
	## since v46 gtk3 is default
	gtk2 +gtk3 -qt5

	## ffmpeg is becoming default, TODO
	+ffmpeg
	-gstreamer # https://anonscm.debian.org/cgit/pkg-mozilla/iceweasel.git/commit/?id=383ee20acf5eab160b4ab0be2b83fb4e4eab9803

	## compiler options
	ccache custom-{cflags,optimization} hardened pgo rust

	## privacy
	-crashreporter -healthreport -safe-browsing -telemetry -wifi

	accessibility +alsa bindist cups dbus debug # +content-sandbox
	gio gnome +gssapi +jemalloc +jit libproxy neon pulseaudio
	+startup-notification

	+system-{icu,jpeg,libevent,libvpx}
	-system-cairo	# buggy, rather use the bundled and patched version
	-system-sqlite	# requires non-standard USE flags

	test +yasm


	+speech-dispatcher -ipdl-tests +webrtc +webspeech +webm +ffmpeg -eme +media-navigator gamepad
)

# deps guide: https://developer.mozilla.org/en-US/docs/Mozilla/Developer_guide/Build_Instructions/Linux_Prerequisites#Other_distros_and_other_Unix-based_systems

gtk_deps=(
	'dev-libs/glib:2'
	'x11-libs/gtk+:2' # gdk-x11-2.0
)

CDEPEND_A=(
	'app-arch/bzip2:0'		# system-bz2
	'app-text/hunspell:0'	# system-hunspell

	'dev-lang/perl:0'		# needed for win32 SDK checks

	'dev-libs/expat:0'

	'=dev-libs/libevent-2.0*:0='	# system-libevent
	'>=dev-libs/nss-3.21.1:0'
	'>=dev-libs/nspr-4.12:0'

	'>=media-gfx/graphite2-1.3.8'	# TODO: check necessity

	'media-libs/fontconfig:1.0'
	'media-libs/freetype:2'
	'>=media-libs/harfbuzz-1.1.3:0=[graphite,icu]'	# TODO: check necessity
	'media-libs/libjpeg-turbo:0'	# system-jpeg
	'>=media-libs/libvpx-1.5.0:0=[postproc]'	# system-libvpx; this is often bumped
	'media-libs/libpng:0=[apng]'
	'media-libs/mesa:0'

	'sys-libs/zlib:0'
	'virtual/libffi:0'	# system-ffi

	'x11-libs/pixman:0'	# system-pixman

	'x11-libs/gdk-pixbuf:2'
	# 'x11-libs/libnotify:0' # we're using a patch to get rid of this
	'x11-libs/libX11:0'
	'x11-libs/libXcomposite:0'
	'x11-libs/libXdamage:0'
	'x11-libs/libXext:0'
	'x11-libs/libXfixes:0'
	'x11-libs/libXrender:0'
	'x11-libs/libXt:0'	# X11/Intrinsic.h, X11/Shell.h

	'accessibility?	( dev-libs/atk:0 )'	# MOZ_ACCESSIBILITY_ATK
	'dbus? ('
		'sys-apps/dbus:0'
		'dev-libs/dbus-glib:0'
	')'
	'gio? ( dev-libs/glib:2 )'
	# Many automated tests will fail with --disable-gconf. See bug 1167201.
	'gconf? ('
		'dev-libs/glib:2'
		'gnome-base/gconf:2'
	')'
	# Enable libgnomeui instead of GIO & GTK for icon theme support
	'gnomeui? ( gnome-base/libgnomeui:0 )'
	'gstreamer? ('
		'media-libs/gstreamer:1.0'
		'media-libs/gst-plugins-base:1.0'
		# 'media-libs/gst-plugins-good:1.0'		# TODO: check necessity
		# 'media-plugins/gst-plugins-libav:1.0'	# TODO: check necessity
	')'
	'gtk2? (' "${gtk_deps[@]}"
			'x11-libs/gtk+:2'
	')'
	'gtk3? (' "${gtk_deps[@]}"
		'x11-libs/gtk+:3'
		'dev-libs/glib:2'
	')'
	'libproxy?	( net-libs/libproxy:0 )'
	'pango? ('
		'x11-libs/pango:0'
	')'
	'pulseaudio?	( media-sound/pulseaudio )'
	'qt5? ('
		'dev-qt/qtcore:5='
		'dev-qt/qtgui:5='
		'dev-qt/qtnetwork:5='
		'dev-qt/qtprintsupport:5='
		'dev-qt/qtwidgets:5='
		'dev-qt/qtxml:5='
		'dev-qt/qtdeclarative:5='
	')'
	# https://bugzilla.mozilla.org/show_bug.cgi?id=1135640
	# https://developer.mozilla.org/en-US/Firefox/Building_Firefox_with_Rust_code
	'rust? ( || ( dev-lang/rust dev-lang/rust-bin ) )'
	'startup-notification? ( x11-libs/startup-notification:0 )'

	'system-cairo? ( x11-libs/cairo:0[X,xcb] )'
	'system-icu? ( dev-libs/icu:0 )'
	# requires SECURE_DELETE, THREADSAFE, ENABLE_FTS3, ENABLE_UNLOCK_NOTIFY, ENABLE_DBSTAT_VTAB
	# reference: configure.in
	'system-sqlite? ( >=dev-db/sqlite-3.9.1:3[secure-delete,debug=] )'

	'webrtc? ('
		'x11-libs/libXext:0'
		'x11-libs/libXdamage:0'
		'x11-libs/libXfixes:0'
		'x11-libs/libXcomposite:0'
	')'
	# wifi is for geolocation only
	'wifi? ( net-misc/networkmanager:0 )'	# TODO: check when is NM needed
)
DEPEND_A=( "${CDEPEND_A[@]}"
	'>=sys-devel/gcc-4.8'
	'virtual/pkgconfig'

	# yasm is required for webm, jpeg (https://developer.mozilla.org/en-US/docs/Mozilla/Developer_guide/Build_Instructions/Yasm)
	'yasm? ( dev-lang/yasm:0 )' # jpeg, libav, libvpx, ...

	"amd64? ("
		'virtual/opengl' # TODO: why this?
	")"
	"x86? ("
		'virtual/opengl' # TODO: why this?
	")"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	'virtual/freedesktop-icon-theme'
	'ffmpeg? ( virtual/ffmpeg )'
)

DEPEND="${DEPEND_A[*]}"
RDEPEND="${RDEPEND_A[*]}"

REQUIRED_USE_A=(
	'^^ ( gtk2 gtk3 qt5 )'
	'wifi? ( dbus )' # FF communicates with NM via dbus
	'crashreporter? ( !bindist )' # contains binary components
	'gio? ( gtk )'
	'startup-notification? ( || ( gtk gtk3 ) )'
	'gtk? ( gio gconf )'
	'gtk3? ( gio gconf )'
	'gnomeui? ( || ( gtk gtk3 ) )'
	'ffmpeg? ( fmp4 )'
	'eme? ( fmp4 )'
)
IUSE="${IUSE_A[*]}"
REQUIRED_USE="${REQUIRED_USE_A[*]}"
RESTRICT+='!bindist? ( bindist )'

# QA_PRESTRIPPED="usr/lib*/${PN}/firefox" # FIXME
# nested configure scripts in mozilla products generate unrecognized options
# false positives when toplevel configure passes downwards.
#QA_CONFIGURE_OPTIONS=".*" # FIXME

S="${WORKDIR}/${MOZ_P}"

BUILD_DIR="${S}/ff"

# --------------------------------------------------------------------------------------------------

# override flaky upstream function
get-flag() {
	local var findflag="${1}"

	# this code looks a little flaky but seems to work for
	# everything we want ...
	# for example, if CFLAGS="-march=i686":
	# `get-flag -march` == "-march=i686"
	# `get-flag march` == "i686"
	for var in $(all-flag-vars) ; do
		# reverse loop
		set -- ${!var}
		local i=$#
		while [ $i -gt 0 ] ; do
			local f="${!i}"
			if [ "${f#-${findflag#-}}" != "${f}" ] ; then
				printf "%s\n" "${f#-${findflag}=}"
				return 0
			fi
			((i--))
		done
	done
	return 1
}

# should be called in both pkg_pretend() and pkg_setup()
# https://developer.mozilla.org/en-US/docs/Mozilla/Developer_guide/Build_Instructions/Linux_Prerequisites#Hardware
my_check_reqs() {
	: CHECKREQS_MEMORY="2G"
	: CHECKREQS_DISK_BUILD="5G"

	if is-flagq '-flto*' && ! is-flagq '-fno-lto' ; then
		local lto=$(get-flag flto)
		# TODO: for each lto process + 1G of MEMORY
		CHECKREQS_MEMORY="4G"
	fi

	use debug && CHECKREQS_MEMORY="6GB"

	# Ensure we have enough disk space to compile
	if use pgo || use debug || use test ; then
		: CHECKREQS_DISK_BUILD="9G" # FIXME
	fi

	check-reqs_pkg_setup
}

# --------------------------------------------------------------------------------------------------

pkg_pretend() {
	my_check_reqs
}

pkg_setup() {
	my_check_reqs

	local export=() unset=()

	# Ensure we use C locale when building
	export+=( LANG='C' LC_ALL='C' )

	# Ensure that we have a sane build enviroment
	export+=( MOZILLA_CLIENT='1' BUILD_OPT='1' NO_STATIC_LIB='1' USE_PTHREADS='1'
		MOZ_MAKE_FLAGS="${MAKEOPTS}" SHELL="${EPREFIX}/bin/bash" )

	# Avoid PGO profiling problems due to enviroment leakage
	# These should *always* be cleaned up anyway
	unset+=( DBUS_SESSION_BUS_ADDRESS DISPLAY ORBIT_SOCKETDIR SESSION_MANAGER XDG_SESSION_COOKIE
		XAUTHORITY )

	echo "Unsetting: $(printf "%s', " "${unset[@]}")"
	unset "${unset[@]}" || die
	echo "Exporting: $(printf "%s', " "${export[@]}")"
	export "${export[@]}" || die

	if ! use bindist ; then
		elog ""
		elog "You are enabling official branding. You may not redistribute this build"
		elog "to any users on your network or the internet. Doing so puts yourself into"
		elog "a legal problem with Mozilla Foundation"
		elog "You can disable it by emerging ${PN} **with** the 'bindist' USE-flag"
	fi

	if use pgo ; then
		elog ""
		elog "You will do a double build for profile guided optimization (PGO)."
		elog "This will result in your build taking at least twice as long as before."
		elog "You can disable it by emerging ${PN} **without** the 'pgo' USE-flag"
	fi

	python-any-r1_pkg_setup
}

# --------------------------------------------------------------------------------------------------

src_prepare() {
	eapply "${FILESDIR}"/patches/

	eapply_user

	# Enable gnomebreakpad
	if use debug ; then
		sed -e 's|'GNOME_DISABLE_CRASH_DIALOG=1'|'GNOME_DISABLE_CRASH_DIALOG=0'|g' \
			-i -- "${S}"/build/unix/run-mozilla.sh || die
	fi

	# Ensure that our plugins dir is enabled as default FIXME: review
	sed -e 's|'/usr/lib/mozilla/plugins'|'/usr/lib/nsbrowser/plugins'|g' \
		-e 's|'/usr/lib64/mozilla/plugins'|'/usr/lib64/nsbrowser/plugins'|g' \
		-i -- "${S}"/xpcom/io/nsAppFileLocationProvider.cpp || die

	# Fix sandbox violations during make clean, bug 372817
	sed -r -e "s|(/no-such-file)|${T}\1|g" \
		-i -- "${S}"/config/rules.mk "${S}"/nsprpub/configure{.in,} || die

	# FIXME: test this
	# Don't exit with error when some libs are missing which we have in
	# system.
# 	sed '/^MOZ_PKG_FATAL_WARNINGS/s@= 1@= 0@' \
# 		-i "${S}"/browser/installer/Makefile.in || die

	# Keep codebase the same even if not using official branding
	sed -r '/^MOZ_DEV_EDITION=1/d' \
		-i -- "${S}"/browser/branding/aurora/configure.sh || die

	sed -e "s|@MOZ_APP_NAME@|${PN}|g" \
		-- "${FILESDIR}"/${PN}.1.in > "${T}"/${PN}.1 || die

	eautoreconf

	# Must run autoconf in js/src FIXME
	cd "${S}"/js/src || die
	eautoconf

	if use jemalloc ; then
		# Need to update jemalloc's configure FIXME
		cd "${S}"/memory/jemalloc/src || die
		# FIXME
		WANT_AUTOCONF= eautoconf
	fi
}

# --------------------------------------------------------------------------------------------------

my::src_configure::compiler() {
	# -O* compiler flags are passed only via `--enable-optimize=` option
	local o="$(get-flag '-O*')"
	if use custom-optimization && [ -n "${o}" ] ; then
		$mozconfig::add_options 'from *FLAGS' --enable-optimize="${o}"
	fi
	filter-flags '-O*'

	# Strip over-aggressive CFLAGS
	use custom-cflags || strip-flags

	# We want rpath support to prevent unneeded hacks on different libc variants
	append-ldflags -Wl,-rpath="${MOZILLA_FIVE_HOME}"

	# Add full relro support for hardened
	use hardened && append-ldflags '-Wl,-z,relro,-z,now'

	# ----------

	$mozconfig::add_options '' --disable-elf-hack # FIXME

	$mozconfig::use_with ccache

	# https://developer.mozilla.org/en-US/docs/Mozilla/Developer_guide/Build_Instructions/Building_with_Profile-Guided_Optimization
	$mozconfig::use_set pgo
	# mk_add_options PROFILE_GEN_SCRIPT='xvfb-run -a @MOZ_PYTHON@ @TOPSRCDIR@/@MOZ_OBJDIR@/_profile/pgo/profileserver.py 10'

	# Currently --enable-elf-dynstr-gc only works for x86,
	# thanks to Jason Wever <weeve@gentoo.org> for the fix.
	if use x86 && [ "$(get-flags '-O*')" != '-O0' ] ; then
		$mozconfig::add_options "${ARCH} optimized build" --enable-elf-dynstr-gc
	fi

	# --- --- ---

	options=( --disable-{install-strip,strip,strip-libs} )
	$mozconfig::add_options 'disable stripping' "${options[@]}"

	if use debug ; then
		options=( --enable-{debug,profiling} --enable-{address,memory,thread}-sanitizer )
		$mozconfig::add_options "$(firefox::use_cmt debug)" "${options[@]}"
	else
		$mozconfig::add_options "$(firefox::use_cmt debug)" --enable-release
	fi
	$mozconfig::use_enable	debug	debug-symbols
	$mozconfig::use_set		!debug	BUILDING_RELEASE
}

my::src_configure::gui() {
	local toolkit toolkit_comment

	if use gtk2 ; then
		toolkit="cairo-gtk2"
		toolkit_comment="$(firefox::use_cmt gtk2)"
	elif use gtk3 ; then
		toolkit="cairo-gtk3"
		toolkit_comment="$(firefox::use_cmt gtk3)"
	elif use qt5 ; then
		elog "Warning: Qt5 GUI toolkit is buggy (USE=qt5)"

		toolkit="cairo-qt"
		toolkit_comment="$(firefox::use_cmt qt5)"

		# need to specify these vars because the qt5 versions are not found otherwise,
		# and setting --with-qtdir overrides the pkg-config include dirs
		local t
		for t in qmake moc rcc ; do
			$mozconfig::stmt 'export'	"${toolkit_comment}" HOST_${t^^}="$(qt5_get_bindir)/${t}"
		done
		$mozconfig::stmt 'unset'	"${toolkit_comment}" 'QTDIR'
		$mozconfig::add_options		"${toolkit_comment}" --disable-gio
	fi

	# TODO: egl
	# Only available on mozilla-overlay for experimentation -- Removed in Gentoo repo per bug 571180
	#use egl && mozconfig_annotate 'Enable EGL as GL provider' --with-gl-provider=EGL

	$mozconfig::add_options "${toolkit_comment}" --enable-default-toolkit="${toolkit}"

	$mozconfig::use_enable system-cairo

	$mozconfig::add_options '' --enable-system-pixman

	# $mozconfig::add_options 'Gentoo default' --disable-skia # FIXME: use or not?
	# --disable-skia-gpu
}

my::src_configure::system_libs() {
	local cmt='system libs' options

	# these are configured via pkg-config
	options=(
		--with-system-{libevent,libvpx,nss}
		--enable-system-{ffi,hunspell} )
	$mozconfig::add_options "${cmt}" "${options[@]}"

	# SQLite
	$mozconfig::use_enable system-sqlite

	# ICU
	$mozconfig::use_with system-icu icu

	# zlib
	$mozconfig::add_options "${cmt} - zlib" --with-system-zlib
	$mozconfig::stmt 'export' "${cmt} - zlib" \
		MOZ_ZLIB_CFLAGS="$(pkg-config --cflags zlib)" MOZ_ZLIB_LIBS="$(pkg-config --libs zlib)"

	# bz2
	$mozconfig::add_options "${cmt} - BZIP2" --with-system-bz2="${EPREFIX}/usr"

	# jpeg
	$mozconfig::add_options "${cmt} - JPEG" --with-system-jpeg="${EPREFIX}/usr"

	# png
	$mozconfig::add_options "${cmt} - PNG" --with-system-png="${EPREFIX}/usr"

	# nspr (--with-system-nspr is deprecated)
	$mozconfig::add_options "${cmt} - NSPR" \
		--with-nspr-cflags="$(pkg-config --cflags nspr)" --with-nspr-libs="$(pkg-config --libs nspr)"
}

src_configure() {
	# get_libdir() is defined only since configure phase, so do not put this in global space
	export MOZILLA_FIVE_HOME="${EPREFIX}/usr/$(get_libdir)/${PN}" || die

	DEFAULT_PREFS_JS="${T}/default-prefs.js"
	cp -v "${FILESDIR}/default-prefs.js" "${DEFAULT_PREFS_JS}" || die

	##
	# mozconfig
	##
	export MOZCONFIG="${S}/mozconfig" || die
	echo >"${MOZCONFIG}" || die

	local mozconfig=firefox::mozconfig # "class"
	$mozconfig::init

	local options # mozconfig options array

	## setup dirs
	options=(
		--x-includes="${EPREFIX}/usr/include" --x-libraries="${EPREFIX}/usr/$(get_libdir)"
		--with-nspr-prefix="${EPREFIX}/usr" --with-nss-prefix="${EPREFIX}/usr"
		# --with-qtdir="$(qt5_get_dir)"
		--with-default-mozilla-five-home="${MOZILLA_FIVE_HOME}"
	)
	$mozconfig::add_options 'paths' "${options[@]}"
	$mozconfig::stmt 'mk_add_options' '' MOZ_OBJDIR="${BUILD_DIR}"

	## setup compiler
	my::src_configure::compiler

	$mozconfig::add_options '' --with-pthreads

	## distribution
	$mozconfig::use_enable !bindist official-branding
	# available brandings: aurora/nightly/official/unofficial
	use bindist && $mozconfig::add_options "$(firefox::use_cmt bindist)" --with-branding='browser/branding/aurora'
	$mozconfig::add_options 'id' --with-distribution-id='org.gentoo'

	$mozconfig::use_enable test tests

	options=( --disable-{installer,updater} )
	$mozconfig::add_options 'disable installer/updater' "${options[@]}"
	# pref("browser.pocket.enabled", true);

	$mozconfig::add_options 'Create a shared JavaScript library' --enable-shared-js

	# jemalloc
	$mozconfig::use_enable	jemalloc
	$mozconfig::use_enable	jemalloc replace-malloc
	$mozconfig::use_set		jemalloc MOZ_JEMALLOC3

	$mozconfig::use_enable jit ion

	$mozconfig::use_enable rust

	my::src_configure::gui

	## system libs
	my::src_configure::system_libs

	# '--enable-build-backend=FasterMake'
	# --disable-startupcache
	# --disable-mozril-geoloc
	# --enable-xterm-updates
	# --disable-synth-speechd

	$mozconfig::use_enable speech-dispatcher
	# --disable-websms-backend
	# use x86 || use amd64 || --disable-webrtc
	# --enable-hardware-aec-ns
	# --disable-webspeech # nightly
	# --disable-webspeechtestbackend # nightly
	# --enable-raw
	# --disable-gamepad
	# --enable-tree-freetype
	# --disable-webapp-runtime
	# --enable-bundled-fonts
	# --enable-verify-mar
	# --enable-signmar
	# --disable-parental-controls
# 	%%if DEB_HOST_ARCH == arm64
# 	ac_add_options --enable-system-ffi
# 	%%endif

	# e10s
	# $mozconfig::use_enable content-sandbox

	$mozconfig::use_enable accessibility
	$mozconfig::add_options 'ECMAScript Internationalization API' --with-intl-api

	## audio
	$mozconfig::use_enable alsa
	$mozconfig::use_enable pulseaudio
	# these are forced-on for webm support FIXME: really?
	$mozconfig::add_options 'required for webm' --enable-{ogg,wave} # FIXME: requires ALSA (https://developer.mozilla.org/en-US/docs/Mozilla/Developer_guide/Build_Instructions/ALSA)

	## video
	$mozconfig::use_enable ffmpeg
	$mozconfig::add_options '' --enable-webm # html5 video
	if use gstreamer ; then
		# FIXME: isn't ffmpeg default now?
		use ffmpeg && einfo "${PN} will not use ffmpeg unless gstreamer:1.0 is not available at runtime"
		$mozconfig::add_options "$(firefox::use_cmt gstreamer)" --enable-gstreamer=1.0
	else
		$mozconfig::add_options "$(firefox::use_cmt gstreamer)" --disable-gstreamer
	fi

	## desktop integration
	$mozconfig::use_enable	startup-notification # TODO: what is this?
	$mozconfig::use_enable	dbus	# MOZ_ENABLE_DBUS

	## privacy
	$mozconfig::use_enable	crashreporter
	$mozconfig::use_set		healthreport	MOZ_SERVICES_HEALTHREPORT
	$mozconfig::use_enable	safe-browsing
	$mozconfig::use_enable	safe-browsing	url-classifier
	$mozconfig::use_set		telemetry		MOZ_TELEMETRY_REPORTING
	# add_pref pref("experiments.enabled", $(usex telemetry true false));
	# pref("toolkit.telemetry.archive.enabled", true);
	$mozconfig::add_options 'popup and cookie blocking' --enable-permissions

	# positioning
	# --enable-approximate-location
	$mozconfig::use_enable	wifi	necko-wifi # positioning wifi scanner

	## Gnome
	$mozconfig::use_enable	gnome	gnomeui
	$mozconfig::use_enable	gnome	gconf
	$mozconfig::use_enable	gio  # MOZ_ENABLE_GIO

	## networking
	$mozconfig::use_enable libproxy
	$mozconfig::use_enable gssapi negotiateauth

	$mozconfig::use_enable cups printing

	## BEGIN: arch specific stuff (keep this at the end to allow overrides)

	# Modifications to better support ARM, bug 553364
	if use neon ; then
		options=( --with-fpu=neon --with-thumb=yes --with-thumb-interwork=no )
		$mozconfig::add_options "$(firefox::use_cmt neon)" "${options[@]}"
	fi
	if [[ ${CHOST} == armv* ]] ; then
		options=( --with-float-abi=hard --enable-skia )
		$mozconfig::add_options "CHOST=armv*" "${options[@]}"

		if ! use system-libvpx ; then
			sed -e "s|softfp|hard|" \
				-i -- "${S}/media/libvpx/moz.build" || die
		fi
	fi

	## END: arch specific stuff (keep this at the end to allow overrides)

	$mozconfig::final

	## ---

	#return 0

	emake -f client.mk configure
}

# --------------------------------------------------------------------------------------------------

src_compile() {
	# return 0

	if use pgo ; then
		# FIXME
# 		addpredict /root
# 		addpredict /etc/gconf

		gnome2_environment_reset

		# FIXME
# 		# Firefox tries to use dri stuff when it's run, see bug 380283
# 		shopt -s nullglob
# 		cards=$(echo -n /dev/dri/card* | sed 's/ /:/g')
# 		if test -z "${cards}"; then
# 			cards=$(echo -n /dev/ati/card* /dev/nvidiactl* | sed 's/ /:/g')
# 			if test -n "${cards}"; then
# 				# Binary drivers seem to cause access violations anyway, so
# 				# let's use indirect rendering so that the device files aren't
# 				# touched at all. See bug 394715.
# 				export LIBGL_ALWAYS_INDIRECT=1
# 			fi
# 		fi
# 		shopt -u nullglob
# 		addpredict "${cards}"
	fi

	# xvfb-run -a -s "-extension GLX -screen 0 1280x1024x24"
	emake -f client.mk build
}

# --------------------------------------------------------------------------------------------------

src_test() {
	return 0
}

# --------------------------------------------------------------------------------------------------

mozconfig_install_prefs() {
	local prefs_file="${1}"

	einfo "Adding prefs from mozconfig to ${prefs_file}"

	# set dictionary path, to use system hunspell
	echo "pref(\"spellchecker.dictionary_path\", \"${EPREFIX}/usr/share/myspell\");" \
		>>"${prefs_file}" || die

		# FIXME
		echo "sticky_pref(\"gfx.font_rendering.graphite.enabled\",true);" \
			>>"${prefs_file}" || die
}

src_install() {
	return 0

	cd -v "${BUILD_OBJ_DIR}" || die

	# FIXME: Add our default prefs for firefox
# 	cp "${FILESDIR}"/gentoo-default-prefs.js-1 \
# 		"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js" \
# 		|| die
# 	mozconfig_install_prefs \
# 		"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js"

	# FIXME: Augment this with hwaccel prefs
# 	if use hwaccel ; then
# 		cat "${FILESDIR}"/gentoo-hwaccel-prefs.js-1 >> \
# 		"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js" \
# 		|| die
# 	fi

	# FIXME
# 	echo "pref(\"extensions.autoDisableScopes\", 3);" >> \
# 		"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js" \
# 		|| die

	# FIXME
# 	local plugin
# 	use gmp-autoupdate || for plugin in \
# 	gmp-gmpopenh264 ; do
# 		echo "pref(\"media.${plugin}.autoupdate\", false);" >> \
# 			"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js" \
# 			|| die
# 	done

	# FIXME
# 	local size sizes icon_path icon name
# 	if use bindist; then
# 		sizes="16 32 48"
# 		icon_path="${S}/browser/branding/aurora"
# 		# Firefox's new rapid release cycle means no more codenames
# 		# Let's just stick with this one...
# 		icon="aurora"
# 		name="Aurora"
#
# 		# Override preferences to set the MOZ_DEV_EDITION defaults, since we
# 		# don't define MOZ_DEV_EDITION to avoid profile debaucles.
# 		# (source: browser/app/profile/firefox.js)
# 		cat >>"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js" <<PROFILE_EOF
# pref("app.feedback.baseURL", "https://input.mozilla.org/%LOCALE%/feedback/firefoxdev/%VERSION%/");
# sticky_pref("lightweightThemes.selectedThemeID", "firefox-devedition@mozilla.org");
# sticky_pref("browser.devedition.theme.enabled", true);
# sticky_pref("devtools.theme", "dark");
# PROFILE_EOF
#
# 	else
# 		sizes="16 22 24 32 256"
# 		icon_path="${S}/browser/branding/official"
# 		icon="${PN}"
# 		name="Mozilla Firefox"
# 	fi
#
# 	# Install icons and .desktop for menu entry
# 	for size in ${sizes}; do
# 		insinto "/usr/share/icons/hicolor/${size}x${size}/apps"
# 		newins "${icon_path}/default${size}.png" "${icon}.png"
# 	done
# 	# The 128x128 icon has a different name
# 	insinto "/usr/share/icons/hicolor/128x128/apps"
# 	newins "${icon_path}/mozicon128.png" "${icon}.png"
# 	newmenu "${FILESDIR}/icon/${PN}.desktop" "${PN}.desktop"
# 	sed -i -e "s:@NAME@:${name}:" -e "s:@ICON@:${icon}:" \
# 		"${ED}/usr/share/applications/${PN}.desktop" || die

	# FIXME
	# Add StartupNotify=true bug 237317
# 	if use startup-notification ; then
# 		echo "StartupNotify=true"\
# 			 >> "${ED}/usr/share/applications/${PN}.desktop" \
# 			|| die
# 	fi

	emake DESTDIR="${ED}" install

	pax-mark m "${ED}${MOZILLA_FIVE_HOME}"/plugin-container
	# Required in order to use plugins and even run firefox on hardened, with jit useflag.
	use jit && pax-mark m "${ED}${MOZILLA_FIVE_HOME}"/{firefox,firefox-bin}

	# Add StartupNotify=true bug 237317
	if use startup-notification ; then
		echo "StartupNotify=true"\
			 >> "${ED}/usr/share/applications/${PN}.desktop" \
			|| die
	fi

	doman "${T}/${PN}.1"
}

# --------------------------------------------------------------------------------------------------

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	# Update mimedb for the new .desktop file
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
