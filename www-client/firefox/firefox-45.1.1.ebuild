# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE='ncurses,sqlite,ssl,threads'

inherit check-reqs flag-o-matic python-any-r1

DESCRIPTION="Firefox Web Browser (rindeal's edition)"
HOMEPAGE='https://www.mozilla.com/firefox'
LICENSE='MPL-2.0 GPL-2 LGPL-2.1'

ESR=true
MOZ_PV="${PV}${ESR:+"esr"}"
MOZ_P="${PN}-${MOZ_PV}"

SLOT='0'
SRC_URI="https://ftp.mozilla.org/pub/firefox/releases/${MOZ_PV}/source/${MOZ_P}.source.tar.xz"

KEYWORDS='~amd64 ~arm ~x86'
IUSE_A=(
	accessibility +alsa bindist custom-{cflags,optimization} dbus debug +ffmpeg gssapi +gstreamer
	gtk2 +gtk3 +jemalloc3 jit libproxy neon pgo
	-qt5 pulseaudio +safe-browsing startup-notification
	system-{cairo,harfbuzz,icu,jpeg,libevent,sqlite,libvpx}
	-telemetry test wifi )
REQUIRED_USE_A=(
	'system-harfbuzz? ( system-icu )'
	'^^ ( gtk2 gtk3 qt5 )'
	'wifi? ( dbus )'
)
IUSE="${IUSE_A[*]}"
REQUIRED_USE="${REQUIRED_USE_A[*]}"
RESTRICT+='!bindist? ( bindist )'

asm_depend="dev-lang/yasm:0"

CDEPEND_A=(
	'app-arch/bzip2:0' # system-bz2
	'app-text/hunspell:0' # system-hunspell

	# perl # needed for win32 SDK checks

	'accessibility? ( dev-libs/atk:0 )' # MOZ_ACCESSIBILITY_ATK
	'dev-libs/expat:0'
	'dev-libs/glib:2'
	'=dev-libs/libevent-2.0*:0=' # system-libevent
	'>=dev-libs/nss-3.21.1:0'
	'>=dev-libs/nspr-4.12:0'

	'>=media-gfx/graphite2-1.3.8' # FIXME: check necessity

	'media-libs/fontconfig:0'
	'media-libs/freetype:2'
	'>=media-libs/harfbuzz-1.1.3:0=[graphite,icu]' # FIXME: check necessity
	'media-libs/libjpeg-turbo:0' # system-jpeg
	'>=media-libs/libvpx-1.5.0:0=[postproc]' # system-libvpx; this is often bumped
	'media-libs/libpng:0=[apng]'
	'media-libs/mesa:0'

	'sys-libs/zlib:0'
	'virtual/libffi:0' # system-ffi

	'x11-libs/cairo:0[X,xcb]' # system-cairo
	'x11-libs/pixman:0' # system-pixman

	'x11-libs/gdk-pixbuf'
	'x11-libs/libX11:0'
	'x11-libs/libXcomposite:0'
	'x11-libs/libXdamage:0'
	'x11-libs/libXext:0'
	'x11-libs/libXfixes:0'
	'x11-libs/libXrender:0'
	'x11-libs/libXt:0'
	'x11-libs/pango:0'

	'pulseaudio? ( media-sound/pulseaudio )'
	'dbus? ('
		'sys-apps/dbus:0'
		'dev-libs/dbus-glib:0'
	')'
	'ffmpeg? ( virtual/ffmpeg )'
	'gstreamer? ('
		'media-libs/gstreamer:1.0'
		'media-libs/gst-plugins-base:1.0'
		# 'media-libs/gst-plugins-good:1.0'
		# 'media-plugins/gst-plugins-libav:1.0'
	')'
	'gtk2? ( x11-libs/gtk+:2 )'
	'gtk3? ( x11-libs/gtk+:3 )'
	'icu? ( dev-libs/icu:= )'
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
	'startup-notification? ( x11-libs/startup-notification:0 )'

	'system-sqlite? ( >=dev-db/sqlite-3.9.1:3[secure-delete,debug=] )'

	'wifi? ( net-misc/networkmanager:0 )'
)
DEPEND_A=( "${CDEPEND_A[@]}"
	'app-arch/zip'
	'app-arch/unzip'
	'sys-devel/binutils:*'
	'virtual/pkgconfig'

	"amd64? ( ${asm_depend}"
		'virtual/opengl' # FIXME: why this?
	")"
	"x86? ( ${asm_depend}"
		'virtual/opengl' # FIXME: why this?
	")"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	'virtual/freedesktop-icon-theme'
)

DEPEND="${DEPEND_A[*]}"
RDEPEND="${RDEPEND_A[*]}"

QA_PRESTRIPPED="usr/lib*/${PN}/firefox"

S="${WORKDIR}/${MOZ_P}"

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
my_check_reqs() {
	is-flagq '-flto*' && ! is-flagq '-fno-lto' && CHECKREQS_MEMORY="6G"

	# Ensure we have enough disk space to compile
	if use pgo || use debug || use test ; then
		: CHECKREQS_DISK_BUILD="8G" # FIXME
	else
		CHECKREQS_DISK_BUILD="4G"
	fi

	check-reqs_pkg_setup
}

pkg_pretend() {
	my_check_reqs
}

pkg_setup() {
	local export=() unset=()

	# Ensure we use C locale when building
	export+=( LANG="C" LC_ALL="C" LC_MESSAGES="C" LC_CTYPE="C" )

	# Ensure that we have a sane build enviroment
	export+=( MOZILLA_CLIENT='1' BUILD_OPT='1' NO_STATIC_LIB='1' USE_PTHREADS='1'
		ALDFLAGS="${LDFLAGS}" )

	# ensure MOZCONFIG is not defined
	unset+=( MOZCONFIG )

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

	my_check_reqs

	python-any-r1_pkg_setup
}

src_prepare() {
	eapply_user
}


my_mozconfig_action() {
	local action="$1" cmt="$2"
	shift 2
	[[ $# -gt 0 ]] || die "${FUNCNAME} called with no flags. Comment: '${cmt}'"

	local x
	for x in "${@}" ; do
		printf "%s %s # %s\n" \
			"${action}" "${x}" "${cmt}" >>"${mozconfig}" || die
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

my_mozconfig_use_extension() {
	local ext="${2}"
	my_mozconfig_options "$(my_use_cmt $1)" $(usex $1 --enable-extensions={,-}${ext})
}

my_src_configure-compiler() {
	# -O* compiler flags are passed only via `--enable-optimize=` option
	local o="$(get-flag '-O*')"
	if use custom-optimization && [ -n "${o}" ] ; then
		my_mozconfig_options 'from *FLAGS' --enable-optimize="${o}"
	else
		my_mozconfig_options 'mozilla default' --enable-optimize
	fi
	filter-flags '-O*'

	# Strip over-aggressive CFLAGS
	use custom-cflags || strip-flags

	# We want rpath support to prevent unneeded hacks on different libc variants
	append-ldflags -Wl,-rpath="${MOZILLA_FIVE_HOME}"

	# ---------------------

	my_mozconfig_options 'disable pedantic' --disable-pedantic
	options=( --disable-{install-strip,strip,strip-libs} )
	my_mozconfig_options 'disable stripping' "${options[@]}"

	# Currently --enable-elf-dynstr-gc only works for x86,
	# thanks to Jason Wever <weeve@gentoo.org> for the fix.
	if use x86 && [ "$(get-flags '-O*')" != '-O0' ] ; then
		my_mozconfig_options "${ARCH} optimized build" --enable-elf-dynstr-gc
	fi

	if use debug ; then
		options=( --enable-{debug,profiling} --enable-{address,memory,thread}-sanitizer )
		my_mozconfig_options 'debug' "${options[@]}"
	fi

	my_mozconfig_options '' --{build,target}=${CTARGET:-${CHOST}} # FIXME: is this necessary
}

my_src_configure-fix_enable-extensions() {
	# Resolve multiple --enable-extensions down to one
	local exts=(
		$(sed -n -r 's|^ac_add_options *--enable-extensions=([^ ]*).*|\1|p' -- "${mozconfig}")
	)
	if [ ${#exts[@]} -gt 1 ] ; then
		local joint="$(IFS=,; echo "${exts[*]}")"
		echo "mozconfig: merging multiple extensions: '${joint}'"
		sed -e '/^ac_add_options *--enable-extensions/d' -i -- "${mozconfig}" || die
		my_mozconfig_options "extensions" --enable-extensions="${joint}"
	fi
}

# @FUNCTION: mozconfig_final
# @DESCRIPTION:
# Display a table describing all configuration options paired
# with reasons, then clean up extensions list.
# This should be called in src_configure at the end of all other mozconfig_* functions.
my_src_configure-dump_config() {
	echo ''
	echo "=========================================================="
	echo "Building ${PF} with the following configuration"
	echo "----------------------------------------------------------"

	local format="%-10s | %-30s # %s\n"
	printf "${format}"
		'action' 'value' 'comment'
	printf "${format}" \
		'---' '---' '---'

	local action val hash cmt
	while read action val hash cmt ; do
		if [ -n "${hash}" ] && [ "${hash}" != '#' ] ; then
			die "error reading mozconfig: '${action}' '${val}' '${hash}' '${cmt}'"
		fi
		printf "${format}" \
			"${action}" "${val}" "${cmt:-"default"}" || die
	done < <( grep '^[^# ]' "${mozconfig}" | sort )
	echo "=========================================================="
	echo ''
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
	# these are configured via pkg-config
	options=( --with-system-{libevent,libvpx,nss} --enable-system-{cairo,ffi,hunspell,pixman} )
	my_mozconfig_options 'system libs' "${options[@]}"

	# requires SECURE_DELETE, THREADSAFE, ENABLE_FTS3, ENABLE_UNLOCK_NOTIFY, ENABLE_DBSTAT_VTAB
	my_mozconfig_use_enable	system-sqlite

	my_mozconfig_use_with icu system-icu

	# zlib
	my_mozconfig_options '' --with-system-zlib
	my_mozconfig_action 'export' '' \
		MOZ_ZLIB_CFLAGS="$(pkg-config --cflags zlib)" MOZ_ZLIB_LIBS="$(pkg-config --libs zlib)"

	# bz2
	my_mozconfig_options '' --with-system-bz2="${EROOT}usr"

	# jpeg
	my_mozconfig_options '' --with-system-jpeg="${EROOT}usr"

	# png
	my_mozconfig_options '' --with-system-png="${EROOT}usr"

	# nspr (--with-system-nspr is deprecated)
	my_mozconfig_options 'NSPR' \
		--with-nspr-cflags="$(pkg-config --cflags nspr)" --with-nspr-libs="$(pkg-config --libs nspr)"
}

src_configure() {
	# get_libdir() is defined only since configure phase, so do not put this in global space
	MOZILLA_FIVE_HOME="${EROOT}usr/$(get_libdir)/${PN}" # --with-default-mozilla-five-home=

	##
	# mozconfig
	##
	local mozconfig="${S}/.mozconfig"

	# Setup the initial `.mozconfig`.
	cp -v 'browser/config/mozconfig' "${mozconfig}" || die

	local options # mozconfig options array

	## setup dirs
	options=(
		--prefix="${EROOT}usr"
		--libdir="${EROOT}usr/$(get_libdir)"
		--x-includes="${EROOT}usr/include" --x-libraries="${EROOT}usr/$(get_libdir)"
		--with-nspr-prefix="${EROOT}usr" --with-nss-prefix="${EROOT}usr"
		--with-qtdir="$(qt5_get_dir)" )
	my_mozconfig_options 'paths' "${options[@]}"
	my_mozconfig_action 'export' ''  PKG_CONFIG_LIBDIR="" # FIXME

	## setup compiler
	my_src_configure-compiler

	my_mozconfig_options '' --enable-release

	## bindist
	my_mozconfig_use_enable !bindist official-branding
	my_mozconfig_use_with bindist branding 'browser/branding/aurora'

	# my_mozconfig_use_enable debug debug-symbols
	my_mozconfig_use_enable test tests

	options=( --disable-{installer,updater} )
	my_mozconfig_options 'disable installer/updater' "${options[@]}"
	my_mozconfig_options 'no crash reporter' --disable-crashreporter # FIXME: can be optional?

	my_mozconfig_options 'Create a shared JavaScript library' --enable-shared-js

	if use jemalloc3 ; then
		# We must force-enable jemalloc 3 via .mozconfig
		my_mozconfig_action 'export' '' MOZ_JEMALLOC3='1'
		my_mozconfig_options 'jemalloc' --enable-jemalloc --enable-replace-malloc
	fi

	my_mozconfig_use_enable jit ion

	my_src_configure-choose_toolkit

	## system libs
	my_src_configure-system_libs

	# '--enable-build-backend=FasterMake'
	# --enable-rust
	# --disable-startupcache
	# --disable-mozril-geoloc
	# --enable-xterm-updates
	# --disable-synth-speechd
	# --disable-websms-backend
	# --disable-webrtc
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

	my_mozconfig_use_enable content-sandbox

	my_mozconfig_use_enable accessibility
	my_mozconfig_options 'ECMAScript Internationalization API' --with-intl-api

	## audio
	my_mozconfig_use_enable alsa
	my_mozconfig_use_enable pulseaudio
	# these are forced-on for webm support FIXME: really?
	my_mozconfig_options 'required for webm' --enable-{ogg,wave}

	## video
	my_mozconfig_use_enable ffmpeg
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
	my_mozconfig_action 'export' 'telemetry' MOZ_TELEMETRY_REPORTING="$(usex telemetry 0 1)"

	# positioning
	# --enable-approximate-location
	my_mozconfig_use_enable wifi necko-wifi # positioning wifi scanner

	## Gnome
	my_mozconfig_options '' --disable-gnomeui
	my_mozconfig_options '' --enable-gio
	my_mozconfig_options '' --disable-gconf

	# my_mozconfig_options 'Gentoo default' --disable-skia # FIXME: use or not?
	# --disable-skia-gpu

	## networking
	my_mozconfig_use_enable libproxy
	my_mozconfig_use_enable gssapi negotiateauth

	my_mozconfig_use_enable cups printing

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

	# --with-mozilla-api-keyfile
	# --with-google-api-keyfile
	# --with-google-oauth-api-keyfile
	# --with-bing-api-keyfile
	# --with-adjust-sdk-keyfile
	# --with-gcm-senderid-keyfile

	my_src_configure-fix_enable-extensions # FIXME: make this unnecessary

	my_src_configure-dump_config

	## ---
}

src_compile() {
	:
}

src_test() {
	:
}

mozconfig_install_prefs() {
	local prefs_file="${1}"

	einfo "Adding prefs from mozconfig to ${prefs_file}"

	# set dictionary path, to use system hunspell
	echo "pref(\"spellchecker.dictionary_path\", \"${EROOT}usr/share/myspell\");" \
		>>"${prefs_file}" || die

	# force the graphite pref if system-harfbuzz is enabled, since the pref cant disable it
	if use system-harfbuzz ; then
		echo "sticky_pref(\"gfx.font_rendering.graphite.enabled\",true);" \
			>>"${prefs_file}" || die
	fi
}

src_install() {
	:
}
