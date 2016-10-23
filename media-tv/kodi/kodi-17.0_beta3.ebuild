# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
inherit rindeal

declare -g -A KODI_STAGES=( ['_p']='_r' ['_alpha']='a' ['_beta']='b' ['_rc']='rc' )
declare -g -A KODI_CODENAMES=( [16]='Jarvis' [17]='Krypton' )

# convert Gentoo PV to Kodi PV
KODI_PV="${PV}"
for _s in "${!KODI_STAGES[@]}" ; do
	KODI_PV="${KODI_PV//"${_s}"/"${KODI_STAGES["${_s}"]}"}"
done ; unset _s

inherit versionator

## python-*.eclass
# Does not work with py3 here
PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="sqlite"

## git-hosting.eclass
GH_URI="github/xbmc/xbmc"
GH_REF="${KODI_PV}-${KODI_CODENAMES["$(get_version_component_range 1)"]}"

inherit eutils
# EXPORT_FUNCTIONS: pkg_setup
inherit linux-info
# EXPORT_FUNCTIONS: pkg_setup
inherit python-single-r1
inherit multiprocessing
inherit autotools
inherit toolchain-funcs
# EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

DESCRIPTION="Kodi is a well-known FOSS media-player and entertainment hub for digital media"
HOMEPAGE="https://kodi.tv/ http://kodi.wiki/ ${HOMEPAGE}"
LICENSE="GPL-2"

SLOT="0"

[[ "${PV}" == *9999* ]] || KEYWORDS="~amd64 ~x86"
IUSE_A=(
	airplay
	airtunes

	+alsa avahi bluetooth bluray caps cec +dbus debug +java midi mysql nfs

	profile +pulseaudio samba sftp test +texturepacker +udisks upnp +upower
	usb

	## rendering
	# recommended by upstream to be on (`docs/README.linux`)
	+opengl
	gles

	## decoding
	+vaapi vdpau

	webserver

	# x11 should be always on on Linux
	+X

	+non-free # disable components with non-compliant licenses

	openmax omxplayer xslt optical-drive lcms +udev docs bindist tegra lirc
)

CDEPEND_A=( "${PYTHON_DEPS}"
	"app-arch/bzip2"
	"app-arch/unzip"
	"app-arch/zip"
	"sys-libs/zlib"
	">=dev-libs/lzo-2"

	"dev-libs/openssl"
	"dev-libs/libgcrypt"
	"net-libs/gnutls"

	"app-i18n/enca"
	"dev-libs/expat"

	"dev-libs/fribidi"
	"dev-db/sqlite:3"
	"dev-libs/libpcre[cxx]"

	"dev-libs/libcdio[-minimal]"

	">=dev-libs/tinyxml-2.6.2[stl]"
	">=dev-libs/yajl-2"
	"dev-python/simplejson[${PYTHON_USEDEP}]"

	"media-fonts/anonymous-pro"
	"media-fonts/corefonts"
	"media-fonts/dejavu"

	"media-libs/flac"
	"media-libs/fontconfig"
	"media-libs/freetype:2"
	"media-libs/jasper"
	"media-libs/jbigkit"
	">=media-libs/libass-0.9.8"
	"media-libs/libmad"
	"media-libs/libmodplug"
	"media-libs/libmpeg2"
	"media-libs/libsamplerate"
	">=media-libs/taglib-1.9"
	"media-libs/tiff:0="



	# libuuid
	"sys-apps/util-linux"

	"media-sound/wavpack"

	"net-misc/curl"
	"virtual/jpeg:0="

	"xslt? ("
		"dev-libs/libxml2"
		"dev-libs/libxslt"
	")"

	"optical-drive? ( dev-libs/libcdio )"
	"lcms? ( media-libs/lcms:2 )"

	"airplay? ( app-pda/libplist:= )"
	"airtunes? ( net-misc/shairplay:= )"
	"alsa? ( media-libs/alsa-lib )"
	"avahi? ( net-dns/avahi )"
	"bluetooth? ( net-wireless/bluez )"
	"bluray? ( >=media-libs/libbluray-0.7.0 )"
	"caps? ( sys-libs/libcap )"
	"cec? ( >=dev-libs/libcec-3.0 )"
	"dbus? ( sys-apps/dbus )"

	# mdnsembedded? ( net-misc/mDNSResponder )

	# "midi? ( sdl2[midi] )" # bundled
	"mysql? ( virtual/mysql )"
	"nfs? ( net-fs/libnfs:= )"

	# FFMPEG_LIBNAMES="libavcodec >= 56.26.100
	#	libavfilter >= 5.11.102
	#	libavformat >= 56.25.101
	#	libavutil >= 54.20.100
	#	libpostproc >= 53.3.100
	#	libswscale >= 3.1.101
	#	libswresample >= 1.1.100"
	">=media-video/ffmpeg-3.0:=[encode,vdpau?]"
	"gles? ( media-libs/mesa[egl,gles2] )"
	"opengl? ("
		"virtual/glu"
		"virtual/opengl"
		# ">=media-libs/glew-1.5.6"
	")"
	"!gles? ( !opengl? ( media-libs/sdl2-gfx ) )"
	"openmax? ( media-libs/libomxil-bellagio )"
	"omxplayer? ( media-video/raspberrypi-omxplayer )"
	"vaapi? ( x11-libs/libva[X] )"
	"vdpau? ("
		"|| (
			>=x11-libs/libvdpau-1.1
			>=x11-drivers/nvidia-drivers-180.51 )"
	")"


	"samba? ( >=net-fs/samba-3.4.6[smbclient(+)] )"
	"sftp? ( net-libs/libssh[sftp] )"
	# "upnp? (  )" # bundled
	# "if libudev is available, we don't need libusb"
	"!udev? ( usb? ( virtual/libusb:1 ) )"

	"webserver? ( net-libs/libmicrohttpd[messages] )"
	"X? ("
		"x11-libs/libX11"
		"x11-libs/libXext"
		"x11-libs/libXrandr"
		"x11-libs/libdrm"
		"media-libs/mesa[egl]"
	")"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"app-arch/xz-utils"
	"dev-lang/swig"
	"dev-libs/crossguid"
	"dev-util/gperf"
	"virtual/pkgconfig"
	"sys-apps/help2man"


	"docs? ("
		# python API docs
		"app-doc/doxygen"
	")"
	"texturepacker? ( media-libs/giflib )"
	"X? ( x11-proto/xineramaproto )"
	"dev-util/cmake"
	"x86? ( dev-lang/nasm )"
	"java? ( virtual/jre )"
	"test? ( dev-cpp/gtest )"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"!media-tv/xbmc"

	"udisks? ( sys-fs/udisks:0 )"
	"upower? ( || ( sys-power/upower sys-power/upower-pm-utils ) )"
)

REQUIRED_USE_A=(
	# "GLES overwrites GL if both set to yes."
	"?? ( gles opengl )"
	# http://trac.kodi.tv/ticket/10552
	# https://bugs.gentoo.org/show_bug.cgi?id=464306
	"?? ( gles vaapi )"
	"openmax? ( gles )"
	"udisks? ( dbus )"
	"upower? ( dbus )"
)

inherit arrays

pkg_setup() {
	CONFIG_CHECK="~IP_MULTICAST"
	ERROR_IP_MULTICAST="
In some cases Kodi needs to access multicast addresses.
Please consider enabling IP_MULTICAST under Networking options.
"

	check_extra_config
	python-single-r1_pkg_setup
}

my_eautoreconf() {
	# some dirs ship generated autotools, some don't
	multijob_init
	local d dirs=(
		tools/depends/native/TexturePacker/src/configure
		$(printf 'f:\n\t@echo $(BOOTSTRAP_TARGETS)\ninclude bootstrap.mk\n' | emake -f - f)
	)
	for d in "${dirs[@]}" ; do
		[[ -e ${d} ]] && continue
		epushd ${d/%configure/.}
		AT_NOELIBTOOLIZE="yes" AT_TOPLEVEL_EAUTORECONF="yes" \
		multijob_child_init eautoreconf
		epopd
	done
	multijob_finish
}

src_prepare() {
	default

	# Do not force any particular ABI or FPU or SIMD compiler flags for arm
	# targets. Let the toolchain and user CFLAGS control that.
	# https://bugs.gentoo.org/400617
	sed -e 's|elif test "$use_arch" = "arm"; then|elif false; then|' \
		-i -- configure.ac || die

	sed -e 's|--enable-static||g' \
		-i -- tools/depends/native/TexturePacker/Makefile || die

	# avoid long delays when powerkit isn't running #348580
	sed -e '/dbus_connection_send_with_reply_and_block/s:-1:3000:' \
		-i -- xbmc/linux/*.cpp || die

	# respect MAKE and MAKEOPTS
	sed -e 's|make |${MAKE:-make} ${MAKEOPTS} |g' \
		-i -- bootstrap || die

	my_eautoreconf
	elibtoolize

	# bootstrap manually
	# https://bugs.gentoo.org/show_bug.cgi?id=558798
	tc-env_build emake -f codegenerator.mk || die

	# Tweak autotool timestamps to avoid regeneration
	find . -type f -exec touch -r configure {} + || die
}

src_configure() {
	# Fix the final version string showing as "exported"
	# instead of the git commit hash.
	export HAVE_GIT=no GIT_REV="${EGIT_VERSION:-exported}"

	# Disable internal func checks as our USE/DEPEND
	# stuff handles this just fine already #408395
	export ac_cv_lib_avcodec_ff_vdpau_vc1_decode_picture=yes
	# Disable documentation generation
	export ac_cv_path_LATEX=no
	# No configure flage for this #403561
	export ac_cv_lib_bluetooth_hci_devid=$(usex bluetooth)
	# https://bugs.gentoo.org/show_bug.cgi?id=434662
	export ac_cv_path_JAVA_EXE=$(which java)

	local myeconfargs=(
		# Portage sets it up itself
		--disable-ccache
		# use only optimizations specified by user
		--disable-optimizations
		# do not use platform-specific configurations for some arm boards
		--without-platform

		--with-ffmpeg=shared

		## generic options
		$(use_enable debug)
		$(use_enable test gtest)		# Google Test
		$(use_enable test shared-lib)	# build libkodi, helpful for tests
		$(use_enable profile profiling)
		$(use_enable "!bindist" non-free)

		$(use_enable dbus)
		$(use_enable udev)
		$(use_enable tegra)		# support for Tegra2 arm
		$(use_enable X x11)

		## rendering
		$(use_enable gles)		# enable OpenGLES rendering
		$(use_enable opengl gl)	# enable OpenGL rendering
		$(use_enable texturepacker)	# enable texturepacker support

		## decoding
		$(use_enable vaapi)		# enable VDPAU decoding
		$(use_enable vdpau)		# enable VAAPI decoding
		$(use_enable openmax)	# enable OpenMax decoding, requires OpenGLES

		## audio outputs
		$(use_enable alsa)
		$(use_enable pulseaudio pulse)

		## formats
		$(use_enable bluray libbluray)
		$(use_enable caps libcap)
		$(use_enable cec libcec)
		$(use_enable midi mid)	# MIDI (.mid) fies support

		## networking
		$(use_enable airplay)
		$(use_enable airtunes)
		$(use_enable avahi)
		$(use_enable upnp)
		$(use_enable samba)
		$(use_enable nfs)
		$(use_enable sftp ssh)
		$(use_enable webserver)

		## devices support
		$(use_enable lirc)	# infrared
		$(use_enable bluetooth libbluetooth)
		$(use_enable optical-drive)
		$(use_enable usb libusb)

		$(use_enable mysql)
		$(use_enable lcms lcms2) # color management
		$(use_enable omxplayer player omxplayer)
		$(use_enable xslt libxslt)

		# TODO: $(use_enable mdnsembedded)

		# TODO: --with-lirc-device=file	# default LIRC device
		# TODO: --enable-codec= # additional codecs from a list of comma separated names,  choices are amcodec and imxvpu
	)

	econf "${myeconfargs[@]}"
}

src_install() {
	MAKEOPTS="${MAKEOPTS} V=1 VERBOSE=1" default

	# unbundle licences
	erm "${ED}"/usr/share/doc/*/{LICENSE.GPL,copying.txt}*

	# TODO sed d OnlyShowIn
	domenu tools/Linux/kodi.desktop

	## icons
	local s
	for s in 16 32 48 256 ; do
		newicon -s "${s}" "media/icon${s}x${s}.png" "${PN}.png"
	done

	# Remove fontconfig settings that are used only on MacOSX.
	# Can't be patched upstream because they just find all files and install
	# them into same structure like they have in git.
# 	RM_V=0 erm "${ED}"/usr/share/kodi/system/players/dvdplayer/etc || die

	python_domodule tools/EventClients/lib/python/xbmcclient.py
	python_newscript "tools/EventClients/Clients/Kodi Send/kodi-send.py" kodi-send
}
