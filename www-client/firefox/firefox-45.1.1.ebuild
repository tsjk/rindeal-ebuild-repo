# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# upstream guide: https://developer.mozilla.org/en-US/docs/Mozilla/Developer_guide/Build_Instructions

EAPI=6

PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE='ncurses,sqlite,ssl,threads'

# will resolve to 2.13, newer don't work (https://bugzilla.mozilla.org/show_bug.cgi?id=104642)
WANT_AUTOCONF="2.1"

inherit autotools check-reqs flag-o-matic python-any-r1

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
	+ffmpeg +gstreamer

	## compiler options
	ccache custom-{cflags,optimization}  hardened pgo rust

	## privacy
	-crashreporter -safe-browsing -telemetry -wifi

	accessibility +alsa bindist +content-sandbox  cups dbus debug
	gnome +gssapi +jemalloc +jit libproxy neon pulseaudio
	+startup-notification

	+system-{icu,jpeg,libevent,libvpx}
	-system-cairo	# buggy, rather use the bundled and patched version
	-system-sqlite	# requires non-standard USE flags

	test +yasm
)
REQUIRED_USE_A=(
	'^^ ( gtk2 gtk3 qt5 )'
	'wifi? ( dbus )'
	'crashreporter? ( !bindist )'
	'yasm? ( ^^ ( amd64 x86 arm64 ) )'
)
IUSE="${IUSE_A[*]}"
REQUIRED_USE="${REQUIRED_USE_A[*]}"
RESTRICT+='!bindist? ( bindist )'


# deps guide: https://developer.mozilla.org/en-US/docs/Mozilla/Developer_guide/Build_Instructions/Linux_Prerequisites#Other_distros_and_other_Unix-based_systems

CDEPEND_A=(
	'app-arch/bzip2:0' # system-bz2
	'app-text/hunspell:0' # system-hunspell

	'dev-lang/perl:0' # needed for win32 SDK checks

	'accessibility? ( dev-libs/atk:0 )' # MOZ_ACCESSIBILITY_ATK
	'dev-libs/expat:0'
	'dev-libs/glib:2'
	'=dev-libs/libevent-2.0*:0=' # system-libevent
	'>=dev-libs/nss-3.21.1:0'
	'>=dev-libs/nspr-4.12:0'

	'>=media-gfx/graphite2-1.3.8' # TODO: check necessity

	'media-libs/fontconfig:1.0'
	'media-libs/freetype:2'
	'>=media-libs/harfbuzz-1.1.3:0=[graphite,icu]' # TODO: check necessity
	'media-libs/libjpeg-turbo:0' # system-jpeg
	'>=media-libs/libvpx-1.5.0:0=[postproc]' # system-libvpx; this is often bumped
	'media-libs/libpng:0=[apng]'
	'media-libs/mesa:0'

	'sys-libs/zlib:0'
	'virtual/libffi:0' # system-ffi

	'x11-libs/pixman:0' # system-pixman

	'x11-libs/gdk-pixbuf:2'
	# 'x11-libs/libnotify:0' # we're using a patch to get rid of this
	'x11-libs/libX11:0'
	'x11-libs/libXcomposite:0'
	'x11-libs/libXdamage:0'
	'x11-libs/libXext:0'
	'x11-libs/libXfixes:0'
	'x11-libs/libXrender:0'
	'x11-libs/libXt:0' # X11/Intrinsic.h, X11/Shell.h
	'x11-libs/pango:0'

	'pulseaudio? ( media-sound/pulseaudio )'
	'dbus? ('
		'sys-apps/dbus:0'
		'dev-libs/dbus-glib:0'
	')'
	'gstreamer? ('
		'media-libs/gstreamer:1.0'
		'media-libs/gst-plugins-base:1.0'
		# 'media-libs/gst-plugins-good:1.0'
		# 'media-plugins/gst-plugins-libav:1.0'
	')'
	'gtk2? ( x11-libs/gtk+:2 )'
	'gtk3? ( x11-libs/gtk+:3 )'
	'libproxy? ( net-libs/libproxy:0 )'
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
	'rust? ( dev-lang/rust )'
	'startup-notification? ( x11-libs/startup-notification:0 )'

	'system-cairo? ( x11-libs/cairo:0[X,xcb] )'
	'system-icu? ( dev-libs/icu:0 )'
	'system-sqlite? ( >=dev-db/sqlite-3.9.1:3[secure-delete,debug=] )'

	'wifi? ( net-misc/networkmanager:0 )' # TODO: check when is NM needed
)
DEPEND_A=( "${CDEPEND_A[@]}"
	'app-arch/zip'
	'app-arch/unzip'

	'sys-devel/binutils:*'
	'>=sys-devel/gcc-4.8'
	'virtual/pkgconfig'

	# yasm is required for webm, jpeg (https://developer.mozilla.org/en-US/docs/Mozilla/Developer_guide/Build_Instructions/Yasm)
	'yasm? ( dev-lang/yasm:0 )'

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

QA_PRESTRIPPED="usr/lib*/${PN}/firefox" # FIXME

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
	CHECKREQS_MEMORY="2G"
	CHECKREQS_DISK_BUILD="5G"

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
	export+=( LANG='C' LC_ALL='C' LC_MESSAGES='C' LC_CTYPE='C' )

	# Ensure that we have a sane build enviroment
	export+=( MOZILLA_CLIENT='1' BUILD_OPT='1' NO_STATIC_LIB='1' USE_PTHREADS='1'
		ALDFLAGS="${LDFLAGS}" )

	# Avoid PGO profiling problems due to enviroment leakage
	# These should *always* be cleaned up anyway
	unset+=( DBUS_SESSION_BUS_ADDRESS DISPLAY ORBIT_SOCKETDIR SESSION_MANAGER XDG_SESSION_COOKIE
		XAUTHORITY )

	# nested configure scripts in mozilla products generate unrecognized options
	# false positives when toplevel configure passes downwards.
	export+=( QA_CONFIGURE_OPTIONS=".*" )

	echo "Unsetting: $(printf "'%s', " "${unset[@]}")"
	unset "${unset[@]}" || die
	echo "Exporting: $(printf "'%s', " "${export[@]}")"
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
	eapply "${FILESDIR}/patches/"

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

	# Need to update jemalloc's configure FIXME
	cd "${S}"/memory/jemalloc/src || die
	WANT_AUTOCONF= eautoconf
}

# --------------------------------------------------------------------------------------------------

my_mozconfig_action() {
	local action="$1" cmt="$2"
	shift 2
	[[ $# -gt 0 ]] || die "${FUNCNAME} called with no flags. Comment: '${cmt}'"

	local x
	for x in "${@}" ; do
		printf "%s %s # %s\n" \
			"${action}" "${x}" "${cmt}" >>"${MOZCONFIG}" || die
	done
}

my_mozconfig_options() {
	my_mozconfig_action 'ac_add_options' "$@"
}

my_use_cmt() {
	echo "USE=$(usex $1 '' '!')$1"
}

my_mozconfig_use_enable() {
	my_mozconfig_options "$(my_use_cmt $1)" $(use_enable "$@")
}

my_mozconfig_use_with() {
	my_mozconfig_options "$(my_use_cmt $1)" $(use_with "$@")
}

# TODO: remove this func
my_mozconfig_use_extension() {
	local ext="${2}"
	my_mozconfig_options "$(my_use_cmt $1)" $(usex $1 --enable-extensions={,-}${ext})
}

# Display a table describing all configuration options paired with reasons.
# It also serves as a dumb config checker.
my_mozconfig_pretty_print() {
	eshopts_push -s extglob

	echo
	printf -- '=%.0s' {1..100}	; echo
	printf -- ' %.0s' {1..20}	; echo "Building ${PF} with the following configuration"
	printf -- '-%.0s' {1..100}	; echo

	local format="%-20s | %-50s # %s\n"
	printf "${format}" \
		' action' ' value' ' comment'
	printf "${format}" \
		"$(printf -- '-%.0s' {1..20})" "$(printf -- '-%.0s' {1..50})" "$(printf -- '-%.0s' {1..20})"

	local line
	while read line ; do
		eval set -- "${line/\#/@}"
		local action="$1" val="$2" at="$3"
		local cmt=
		[[ "${line}" == *\#* ]] && cmt="${line##*#*( )}"
		: ${cmt:="default"}

		if [ -n "${at}" ] && [ "${at}" != '@' ] ; then
			die "error reading mozconfig: '${action}' '${val}' '${at}' '${cmt}'"
		fi

		printf "${format}" \
			"${action}" "${val}" "${cmt}" || die
	done < <( grep '^[^# ]' "${MOZCONFIG}" | sort )
	printf -- '=%.0s' {1..100} ; echo
	echo

	eshopts_pop
}

my_default_pref() {
	local name="$1" val="$2" cmt="$3"

	if ! [[ "${val}" =~ ^(-?[0-9]+|true|false)$ ]] ; then
		val="\""${val}\"""
	fi

	printf 'pref("%s", %s); // %s' \
		"${name}" "${val}" "${cmt}" >>"${DEFAULT_PREFS_JS}" || die
}

# --------------------------------------------------------------------------------------------------

my_src_configure-compiler() {
	# -O* compiler flags are passed only via `--enable-optimize=` option
	local o="$(get-flag '-O*')"
	if use custom-optimization && [ -n "${o}" ] ; then
		my_mozconfig_options 'from *FLAGS' --enable-optimize="${o}"
	fi
	filter-flags '-O*'

	# Strip over-aggressive CFLAGS
	use custom-cflags || strip-flags

	# We want rpath support to prevent unneeded hacks on different libc variants
	append-ldflags -Wl,-rpath="${MOZILLA_FIVE_HOME}"

	# Add full relro support for hardened
	use hardened && append-ldflags "-Wl,-z,relro,-z,now"

	my_mozconfig_options '' --disable-elf-hack

	my_mozconfig_use_with ccache

	# https://developer.mozilla.org/en-US/docs/Mozilla/Developer_guide/Build_Instructions/Building_with_Profile-Guided_Optimization
	my_mozconfig_action 'export' "$(my_use_cmt pgo)" MOZ_PGO=$(usex pgo 1 0)
	# mk_add_options PROFILE_GEN_SCRIPT='xvfb-run -a @MOZ_PYTHON@ @TOPSRCDIR@/@MOZ_OBJDIR@/_profile/pgo/profileserver.py 10'

	# Currently --enable-elf-dynstr-gc only works for x86,
	# thanks to Jason Wever <weeve@gentoo.org> for the fix.
	if use x86 && [ "$(get-flags '-O*')" != '-O0' ] ; then
		my_mozconfig_options "${ARCH} optimized build" --enable-elf-dynstr-gc
	fi

	# --- --- ---

	my_mozconfig_options 'disable pedantic' --disable-pedantic
	options=( --disable-{install-strip,strip,strip-libs} )
	my_mozconfig_options 'disable stripping' "${options[@]}"

	if use debug ; then
		options=( --enable-{debug,profiling} --enable-{address,memory,thread}-sanitizer )
		my_mozconfig_options 'debug' "${options[@]}"
	else
		my_mozconfig_options '' --enable-release
		my_mozconfig_action 'export' '' BUILDING_RELEASE=1
	fi
}

my_src_configure-choose_toolkit() {
	local toolkit toolkit_comment

	if use gtk2 ; then
		toolkit="cairo-gtk2"
		toolkit_comment="$(my_use_cmt gtk2)"
	elif use gtk3 ; then
		toolkit="cairo-gtk3"
		toolkit_comment="$(my_use_cmt gtk3)"
	elif use qt5 ; then
		elog "Warning: Qt5 GUI toolkit is buggy (USE=qt5)"

		toolkit="cairo-qt"
		toolkit_comment="$(my_use_cmt qt5)"

		# need to specify these vars because the qt5 versions are not found otherwise,
		# and setting --with-qtdir overrides the pkg-config include dirs
		local t
		for t in qmake moc rcc ; do
			my_mozconfig_action 'export' '' HOST_${t^^}="'$(qt5_get_bindir)/${t}'"
		done
		my_mozconfig_action 'unset' "${toolkit_comment}" 'QTDIR'
		my_mozconfig_options "${toolkit_comment}" --disable-gio
	fi

	my_mozconfig_options "${toolkit_comment}" --enable-default-toolkit="${toolkit}"
}

my_src_configure-system_libs() {
	local cmt='system libs'

	# these are configured via pkg-config
	options=( --with-system-{libevent,libvpx,nss} --enable-system-{ffi,hunspell,pixman} )
	my_mozconfig_options "${cmt}" "${options[@]}"

	my_mozconfig_use_enable system-cairo

	# requires SECURE_DELETE, THREADSAFE, ENABLE_FTS3, ENABLE_UNLOCK_NOTIFY, ENABLE_DBSTAT_VTAB
	my_mozconfig_use_enable	system-sqlite

	my_mozconfig_use_with system-icu icu

	# zlib
	my_mozconfig_options "${cmt} - zlib" --with-system-zlib
	my_mozconfig_action 'export' "${cmt} - zlib" \
		MOZ_ZLIB_CFLAGS="$(pkg-config --cflags zlib)" MOZ_ZLIB_LIBS="$(pkg-config --libs zlib)"

	# bz2
	my_mozconfig_options "${cmt} - BZIP2" --with-system-bz2="${EROOT}usr"

	# jpeg
	my_mozconfig_options "${cmt} - JPEG" --with-system-jpeg="${EROOT}usr"

	# png
	my_mozconfig_options "${cmt} - PNG" --with-system-png="${EROOT}usr"

	# nspr (--with-system-nspr is deprecated)
	my_mozconfig_options "${cmt} - NSPR" \
		--with-nspr-cflags="'$(pkg-config --cflags nspr)'" --with-nspr-libs="'$(pkg-config --libs nspr)'"
}

my_src_configure-keyfiles() {
	my_keyfile() {
		local name="$1" ; shift
		local file="${T}/.${name}"
		echo -n "$@" >"${file}" || die
		my_mozconfig_options "${name}" --with-${name}-keyfile="'${file}'"
	}

	# Google API keys (see http://www.chromium.org/developers/how-tos/api-keys)
	# Note: These are for Gentoo Linux use ONLY. For your own distribution, please
	# get your own set of keys.
	my_keyfile 'google-api'			'AIzaSyDEAOvatFo0eTgsV_ZlEzx0ObmepsMzfAc'

	# FIXME: these are from Arch

	# for Loop/Hello service (https://wiki.mozilla.org/Loop/OAuth_Setup)
	my_keyfile 'google-oauth-api'	'413772536636.apps.googleusercontent.com 0ZChLK6AxeA3Isu96MkwqDR4'

	# for geolocation
	# pref("geo.wifi.uri", "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%");
	my_keyfile 'mozilla-api'		'16674381-f021-49de-8622-3021c5942aff'

	# --with-bing-api-keyfile		# windows only
	# --with-adjust-sdk-keyfile		# mozilla tracking
	# --with-gcm-senderid-keyfile	# android only
}

my_src_configure-fix_enable-extensions() {
	# Resolve multiple --enable-extensions down to one
	local exts=(
		$(sed -n -r 's|^ac_add_options *--enable-extensions=([^ ]*).*|\1|p' -- "${MOZCONFIG}")
	)
	if [ ${#exts[@]} -gt 1 ] ; then
		local joint="$(IFS=,; echo "${exts[*]}")"
		echo "mozconfig: merging multiple extensions: '${joint}'"
		sed -e '/^ac_add_options *--enable-extensions/d' \
			-i -- "${MOZCONFIG}" || die
		my_mozconfig_options "extensions" --enable-extensions="${joint}"
	fi
}

src_configure() {
	# get_libdir() is defined only since configure phase, so do not put this in global space
	export MOZILLA_FIVE_HOME="${EROOT}usr/$(get_libdir)/${PN}" # --with-default-mozilla-five-home=

	DEFAULT_PREFS_JS="${T}/default-prefs.js"
	cp -v "${FILESDIR}/default-prefs.js" "${DEFAULT_PREFS_JS}" || die

	##
	# mozconfig
	##
	export MOZCONFIG="${S}/mozconfig"
	touch "${MOZCONFIG}" || die

	local options # mozconfig options array

	my_mozconfig_options '' --enable-application=browser

	## setup dirs
	options=(
		--prefix="'${EROOT}usr'"
		--libdir="'${EROOT}usr/$(get_libdir)'"
		--x-includes="'${EROOT}usr/include'" --x-libraries="'${EROOT}usr/$(get_libdir)'"
		--with-nspr-prefix="'${EROOT}usr'" --with-nss-prefix="'${EROOT}usr'"
		# --with-qtdir="$(qt5_get_dir)"
		--with-default-mozilla-five-home="'${MOZILLA_FIVE_HOME}'"
	)
	my_mozconfig_options 'paths' "${options[@]}"
	my_mozconfig_action 'mk_add_options' '' MOZ_OBJDIR="'${BUILD_DIR}'"

	## setup compiler
	my_src_configure-compiler

	my_mozconfig_options '' --with-pthreads

	## distribution
	my_mozconfig_use_enable !bindist official-branding
	# available brandings: aurora/nightly/official/unofficial
	my_mozconfig_use_with bindist branding 'browser/branding/aurora'
	my_mozconfig_options 'id' --with-distribution-id='eu.rindeal'

	# my_mozconfig_use_enable debug debug-symbols # FIXME
	my_mozconfig_use_enable test tests

	options=( --disable-{installer,updater} )
	my_mozconfig_options 'disable installer/updater' "${options[@]}"
	my_mozconfig_use_enable crashreporter

	my_mozconfig_options 'Create a shared JavaScript library' --enable-shared-js

	use jemalloc && my_mozconfig_action 'export' "$(my_use_cmt jemalloc)" MOZ_JEMALLOC3="1"
	my_mozconfig_use_enable jemalloc
	my_mozconfig_use_enable jemalloc replace-malloc

	my_mozconfig_use_enable jit ion

	my_mozconfig_use_enable rust # TODO: what excatly does this enable?

	my_src_configure-choose_toolkit

	# Only available on mozilla-overlay for experimentation -- Removed in Gentoo repo per bug 571180
	#use egl && mozconfig_annotate 'Enable EGL as GL provider' --with-gl-provider=EGL

	## system libs
	my_src_configure-system_libs

	# '--enable-build-backend=FasterMake'
	# --enable-rust
	# --disable-startupcache
	# --disable-mozril-geoloc
	# --enable-xterm-updates
	# --disable-synth-speechd
	# --disable-websms-backend
	# use x86 || use amd64 || --disable-webrtc
	# --enable-hardware-aec-ns
	# --disable-webspeech
	# --disable-webspeechtestbackend
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

	my_mozconfig_use_enable content-sandbox

	my_mozconfig_use_enable accessibility
	my_mozconfig_options 'ECMAScript Internationalization API' --with-intl-api

	## audio
	my_mozconfig_use_enable alsa
	my_mozconfig_use_enable pulseaudio
	# these are forced-on for webm support FIXME: really?
	my_mozconfig_options 'required for webm' --enable-{ogg,wave} # FIXME: requires ALSA (https://developer.mozilla.org/en-US/docs/Mozilla/Developer_guide/Build_Instructions/ALSA)

	## video
	my_mozconfig_use_enable ffmpeg
	my_mozconfig_options '' --enable-webm # html5 video
	if use gstreamer ; then
		# FIXME: isn't ffmpeg default now?
		use ffmpeg && einfo "${PN} will not use ffmpeg unless gstreamer:1.0 is not available at runtime"
		my_mozconfig_options "$(my_use_cmt gstreamer)" --enable-gstreamer=1.0
	else
		my_mozconfig_options "$(my_use_cmt gstreamer)" --disable-gstreamer
	fi

	## desktop integration
	my_mozconfig_use_enable startup-notification # TODO: what is this?
	my_mozconfig_use_enable dbus

	## privacy
	my_mozconfig_use_enable safe-browsing # privacy
	my_mozconfig_use_enable safe-browsing url-classifier
	my_mozconfig_action 'export' "$(my_use_cmt telemetry)" MOZ_TELEMETRY_REPORTING="$(usex telemetry 1 0)"

	# positioning
	# --enable-approximate-location
	my_mozconfig_use_enable wifi necko-wifi # positioning wifi scanner

	## Gnome
	my_mozconfig_use_enable gnome gnomeui
	my_mozconfig_use_enable gnome gconf
	my_mozconfig_options '' --enable-gio


	# my_mozconfig_options 'Gentoo default' --disable-skia # FIXME: use or not?
	# --disable-skia-gpu

	## networking
	my_mozconfig_use_enable libproxy
	my_mozconfig_use_enable gssapi negotiateauth

	my_mozconfig_use_enable cups printing

	my_src_configure-keyfiles

	## arch specific options (keep this at the end to allow overrides)

	# Modifications to better support ARM, bug 553364
	if use neon ; then
		my_mozconfig_options '' --with-fpu=neon
		my_mozconfig_options '' --with-thumb=yes
		my_mozconfig_options '' --with-thumb-interwork=no
	fi
	if [[ ${CHOST} == armv* ]] ; then
		my_mozconfig_options '' --with-float-abi=hard
		my_mozconfig_options '' --enable-skia

		if ! use system-libvpx ; then
			sed -e "s|softfp|hard|" \
				-i  -- "${S}/media/libvpx/moz.build" || die
		fi
	fi

	my_src_configure-fix_enable-extensions # FIXME: make this unnecessary

	my_mozconfig_pretty_print

	## ---

	return 0

	emake -f client.mk configure
}

# --------------------------------------------------------------------------------------------------

src_compile() {
	return 0

	emake -f client.mk
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
	echo "pref(\"spellchecker.dictionary_path\", \"${EROOT}usr/share/myspell\");" \
		>>"${prefs_file}" || die

		# FIXME
		echo "sticky_pref(\"gfx.font_rendering.graphite.enabled\",true);" \
			>>"${prefs_file}" || die
}

src_install() {
	return 0

	emake -f client.mk install

	doman "${T}/${PN}.1"
}
