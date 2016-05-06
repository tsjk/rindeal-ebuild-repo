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
RESTRICT+=''
IUSE_A=(
	bindist custom-{cflags,optimization} dbus debug ffmpeg +gstreamer gtk3 +jemalloc3 jit neon pgo -qt5 pulseaudio
	startup-notification
	system-{cairo,harfbuzz,icu,jpeg,libevent,sqlite,libvpx}
	test wifi )
REQUIRED_USE_A=(
	'system-harfbuzz? ( system-icu )'
	'?? ( gtk3 qt5 )'
)
IUSE="${IUSE_A[*]}"
REQUIRED_USE="${REQUIRED_USE_A[*]}"

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
	local var findflag="-${1#-}" findflag_orig="${1}"

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
			if [ "${f#${findflag}}" != "${f}" ] ; then
				printf "%s\n" "${f#-${findflag_orig}=}"
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

# @FUNCTION: mozconfig_annotate
# @DESCRIPTION:
# add an annotated line to .mozconfig
#
# Example:
# mozconfig_annotate "building on ultrasparc" --enable-js-ultrasparc
# => ac_add_options --enable-js-ultrasparc # building on ultrasparc
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

my_src_configure-fix_flags() {
	ewarn $(get-flag '-O*'), $(get-flag 'O*'), $(get-flag 'flto*'), $(get-flag 'march')
	# -O* compiler flags are passed only via `--enable-optimize=` option
	if use custom-optimization ; then
		my_mozconfig_add_options 'from *FLAGS' --enable-optimize="$(get-flag '-O*')"
	else
		my_mozconfig_add_options 'mozilla default' --enable-optimize
	fi
	filter-flags '-O*'

	# Strip over-aggressive CFLAGS
	use custom-cflags || strip-flags
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
	local ac opt hash cmt
	echo
	echo "=========================================================="
	echo "Building ${PF} with the following configuration"
	echo "----------------------------------------------------------"
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
	local mozconfig="${S}/.mozconfig"

	# Setup the initial `.mozconfig`. See http://www.mozilla.org/build/configure-build.html
	cp -v 'browser/config/mozconfig' "${mozconfig}" || die

	my_src_configure-fix_flags

	local options

	my_mozconfig_add_options 'disable pedantic' --disable-pedantic

	options=( --disable-{installer,updater} )
	my_mozconfig_add_options 'disable installer/updater' "${options[@]}"

	options=( --disable-{install-strip,strip,strip-libs} )
	my_mozconfig_add_options 'disable stripping' "${options[@]}"

	# Currently --enable-elf-dynstr-gc only works for x86,
	# thanks to Jason Wever <weeve@gentoo.org> for the fix.
	if use x86 && [ "$(get-flags '-O*')" != -O0 ] ; then
		my_mozconfig_add_options "${ARCH} optimized build" --enable-elf-dynstr-gc
	fi

# 	'--enable-build-backend=FasterMake'
# 	'--enable-release'
# 	# --enable-rust
# 	'--with-x'

	my_src_configure-fix_enable-extensions

	my_src_configure-dump_config
}

src_compile() {
	:
}
