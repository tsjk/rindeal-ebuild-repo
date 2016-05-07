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
	bindist custom-{cflags,optimization} dbus debug ffmpeg +gstreamer gtk3 +jemalloc3 jit neon pgo
	-qt5 pulseaudio startup-notification
	system-{cairo,harfbuzz,icu,jpeg,libevent,sqlite,libvpx}
	test wifi )
REQUIRED_USE_A=(
	'system-harfbuzz? ( system-icu )'
	'?? ( gtk3 qt5 )'
	'wifi? ( dbus )'
)
IUSE="${IUSE_A[*]}"
REQUIRED_USE="${REQUIRED_USE_A[*]}"
RESTRICT+='!bindist? ( bindist )'

asm_depend="dev-lang/yasm:0"

CDEPEND_A=(
	'app-text/hunspell:0'
	'dev-libs/atk:0'
	'dev-libs/expat:0'
	'dev-libs/glib:2'
	'>=dev-libs/nss-3.21.1:0'
	'>=dev-libs/nspr-4.12:0'

	'media-libs/libpng:0=[apng]'
	'media-libs/mesa:0'
	'media-libs/fontconfig:0'
	'media-libs/freetype:2'

	'sys-libs/zlib:0'
	'virtual/libffi:0'

	'x11-libs/cairo:0[X]' # FIXME: is this required for `!system-cairo`?
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
		'media-libs/gst-plugins-good:1.0'
		'media-plugins/gst-plugins-libav:1.0'
	')'
	'gtk3? ( x11-libs/gtk+:3 )'
	'!gtk3? ( x11-libs/gtk+:2 )'
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

	'system-cairo? ('
		'x11-libs/cairo:0[X,xcb]'
		'x11-libs/pixman:0'
	')'
	'system-icu? ( dev-libs/icu:= )'
	'system-jpeg? ( media-libs/libjpeg-turbo:0 )'
	'system-libevent? ( =dev-libs/libevent-2.0*:0= )'
	'system-libvpx? ( >=media-libs/libvpx-1.5.0:0=[postproc] )' # this is often bumped
	'system-sqlite? ( >=dev-db/sqlite-3.9.1:3[secure-delete,debug=] )'
	'system-harfbuzz? ('
		'>=media-libs/harfbuzz-1.1.3:0=[graphite,icu]'
		'>=media-gfx/graphite2-1.3.8'
	')'
	'wifi? ('
		'sys-apps/dbus:0'
		'dev-libs/dbus-glib:0'
		'net-misc/networkmanager:0'
	')'
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


my_mozconfig_add_options() {
	local cmt="$1"
	shift
	[[ $# -gt 0 ]] || die "${FUNCNAME} called with no flags. Comment: '${cmt}'"

	local o
	for o in "${@}" ; do
		printf "ac_add_options %s # %s\n" \
			"${o}" "${cmt}" >>"${mozconfig}" || die
	done
}

my_mozconfig_use_enable() {
	my_mozconfig_add_options "USE=$(usex $1 '' '!')$1" $(use_enable "$@")
}

my_mozconfig_use_with() {
	my_mozconfig_add_options "USE=$(usex $1 '' '!')$1" $(use_with "$@")
}

my_mozconfig_use_extension() {
	local ext="${2}"
	my_mozconfig_add_options "USE=$(usex $1 '' '!')$1" $(usex $1 --enable-extensions={,-}${ext})
}


my_src_configure-fix_flags() {
	# -O* compiler flags are passed only via `--enable-optimize=` option
	local o="$(get-flag '-O*')"
	if use custom-optimization && [ -n "${o}" ] ; then
		my_mozconfig_add_options 'from *FLAGS' --enable-optimize="${o}"
	else
		my_mozconfig_add_options 'mozilla default' --enable-optimize
	fi
	filter-flags '-O*'

	# Strip over-aggressive CFLAGS
	use custom-cflags || strip-flags

	# We want rpath support to prevent unneeded hacks on different libc variants
	append-ldflags -Wl,-rpath="${MOZILLA_FIVE_HOME}"
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
		my_mozconfig_add_options "extensions" --enable-extensions="${joint}"
	fi
}

# @FUNCTION: mozconfig_final
# @DESCRIPTION:
# Display a table describing all configuration options paired
# with reasons, then clean up extensions list.
# This should be called in src_configure at the end of all other mozconfig_* functions.
my_src_configure-dump_config() {
	echo
	echo "=========================================================="
	echo "Building ${PF} with the following configuration"
	echo "----------------------------------------------------------"
	local ac opt hash cmt
	while read ac opt hash cmt ; do
		if [ -n "${hash}" ] && [ "${hash}" != '#' ] ; then
			die "error reading mozconfig: '${ac}' '${opt}' '${hash}' '${reason}'"
		fi
		printf "  %-30s | %s\n" \
			"${opt}" "${cmt:-"mozilla.org default"}" || die
	done < <( grep '^ac_add_options' "${mozconfig}" )
	echo "=========================================================="
	echo
}

src_configure() {
	# get_libdir() is defined only since configure phase
	MOZILLA_FIVE_HOME="${EROOT}usr/$(get_libdir)/${PN}" # --with-default-mozilla-five-home=

	##
	# mozconfig
	##
	local mozconfig="${S}/.mozconfig"

	# Setup the initial `.mozconfig`. See http://www.mozilla.org/build/configure-build.html
	cp -v 'browser/config/mozconfig' "${mozconfig}" || die

	my_src_configure-fix_flags

	local options # mozconfig options array

	my_mozconfig_add_options 'disable pedantic' --disable-pedantic

	options=( --disable-{installer,updater} )
	my_mozconfig_add_options 'disable installer/updater' "${options[@]}"

	options=( --disable-{install-strip,strip,strip-libs} )
	my_mozconfig_add_options 'disable stripping' "${options[@]}"

	# Currently --enable-elf-dynstr-gc only works for x86,
	# thanks to Jason Wever <weeve@gentoo.org> for the fix.
	if use x86 && [ "$(get-flags '-O*')" != '-O0' ] ; then
		my_mozconfig_add_options "${ARCH} optimized build" --enable-elf-dynstr-gc
	fi

	## system
	options=( --enable-{pango,svg} --with-system-{bz2,nspr,nss,png,zlib} --enable-system-{ffi,hunspell} )
	my_mozconfig_add_options 'system libs' "${options[@]}"
	my_mozconfig_use_enable	system-cairo
	my_mozconfig_use_with	system-harfbuzz
	my_mozconfig_use_with	system-harfbuzz system-graphite2
	my_mozconfig_use_with	system-icu
	my_mozconfig_use_with	system-jpeg
	my_mozconfig_use_with	system-libvpx
	my_mozconfig_use_enable	system-sqlite

	## bindist
	my_mozconfig_use_enable !bindist official-branding
	my_mozconfig_use_with bindist branding 'browser/branding/aurora'

	# '--enable-build-backend=FasterMake'
	# '--enable-release'
	# --enable-rust
	# '--with-x'

	if use debug ; then
		options=( --enable-{debug,profiling} --enable-{address,memory,thread}-sanitizer )
		my_mozconfig_add_options 'debug' "${options[@]}"
	fi
	# my_mozconfig_use_enable debug debug-symbols
	my_mozconfig_use_enable test tests

	# TODO: what is this?
	my_mozconfig_use_enable startup-notification

	my_mozconfig_use_enable dbus
	my_mozconfig_use_enable wifi necko-wifi

	# these are forced-on for webm support
	my_mozconfig_add_options 'required' --enable-{ogg,wave}

	my_mozconfig_use_enable jit ion

	# setup dirs
	options=( --x-includes="${EPREFIX}/usr/include" --x-libraries="${EPREFIX}/usr/$(get_libdir)"
        --with-nspr-prefix="${EPREFIX}/usr" --with-nss-prefix="${EPREFIX}/usr"
        --prefix="${EPREFIX}/usr"
        --libdir="${EPREFIX}/usr/$(get_libdir)" )
	my_mozconfig_add_options '' --{build,target}=${CTARGET:-${CHOST}} # FIXME: is this necessary

	my_mozconfig_add_options '' "${options[@]}"
	my_mozconfig_use_with {,}system-libevent "${EPREFIX}/usr"
	my_mozconfig_add_options '' --disable-gnomeui
	my_mozconfig_add_options '' --enable-gio
	my_mozconfig_add_options 'no crash reporter' --disable-crashreporter # FIXME: can be optional?
	my_mozconfig_add_options 'Gentoo default to honor system linker' --disable-gold
	my_mozconfig_add_options 'Gentoo default' --disable-skia
	my_mozconfig_add_options '' --disable-gconf
	my_mozconfig_add_options '' --with-intl-api

		# default toolkit is cairo-gtk2, optional use flags can change this
	local toolkit="cairo-gtk2"
	local toolkit_comment=""
	if use gtk3 ; then
		toolkit="cairo-gtk3"
		toolkit_comment="gtk3 use flag"
	fi
	if use qt5 ; then
		toolkit="cairo-qt"
		toolkit_comment="qt5 use flag"
		# need to specify these vars because the qt5 versions are not found otherwise,
		# and setting --with-qtdir overrides the pkg-config include dirs
		local i
		for i in qmake moc rcc ; do
			echo "export HOST_${i^^}=\"$(qt5_get_bindir)/${i}\"" \
				>>"${mozconfig}" || die
		done
		echo 'unset QTDIR' >>"${mozconfig}" || die
		my_mozconfig_add_options '+qt5' --disable-gio
	fi
	my_mozconfig_add_options "${toolkit_comment}" --enable-default-toolkit=${toolkit}

	if use jemalloc3 ; then
		# We must force-enable jemalloc 3 via .mozconfig
		echo "export MOZ_JEMALLOC3=1" >>"${mozconfig}" || die
		my_mozconfig_add_options 'jemalloc' --enable-jemalloc --enable-replace-malloc
	fi

	my_mozconfig_use_enable ffmpeg
	if use gstreamer ; then
		use ffmpeg && einfo "${PN} will not use ffmpeg unless gstreamer:1.0 is not available at runtime"
		my_mozconfig_add_options '+gstreamer' --enable-gstreamer=1.0
	elif use gstreamer-0 ; then
		use ffmpeg && einfo "${PN} will not use ffmpeg unless gstreamer:0.10 is not available at runtime"
		my_mozconfig_add_options '+gstreamer-0' --enable-gstreamer=0.10
	else
		my_mozconfig_add_options '' --disable-gstreamer
	fi

	my_mozconfig_use_enable pulseaudio

	# Modifications to better support ARM, bug 553364
	if use neon ; then
		my_mozconfig_add_options '' --with-fpu=neon
		my_mozconfig_add_options '' --with-thumb=yes
		my_mozconfig_add_options '' --with-thumb-interwork=no
	fi
	if [[ ${CHOST} == armv* ]] ; then
		my_mozconfig_add_options '' --with-float-abi=hard
		my_mozconfig_add_options '' --enable-skia

		if ! use system-libvpx ; then
			sed -e "s|softfp|hard|" \
				-i  -- "${S}/media/libvpx/moz.build" || die
		fi
	fi

	my_src_configure-fix_enable-extensions

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
	echo "pref(\"spellchecker.dictionary_path\", \"${EPREFIX}/usr/share/myspell\");" \
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
