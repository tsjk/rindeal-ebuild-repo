# Copyright 1999-2015 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GH_URI="github/kcat/openal-soft"
GH_REF="openal-soft-${PV}"

inherit cmake-utils-patched git-hosting xdg eutils

DESCRIPTION="A software implementation of the OpenAL 3D audio API"
HOMEPAGE="http://kcat.strangesoft.net/openal.html ${HOMEPAGE}"
LICENSE="LGPL-2+"

SLOT="0"

KEYWORDS="amd64 ~arm"
backends=( alsa coreaudio jack oss portaudio pulseaudio )
IUSE_A=(
	${backends[@]}
	debug examples gui tests utils
	cpu_flags_x86_{sse,sse2,sse3,sse4_1} neon
)

RDEPEND="
	alsa? ( media-libs/alsa-lib )
	examples? (
		media-libs/libsdl2[sound]
		media-video/ffmpeg
	)
	jack? ( media-sound/jack-audio-connection-kit )
	portaudio? ( media-libs/portaudio )
	pulseaudio? ( media-sound/pulseaudio )
	gui? (
		dev-qt/qtgui:4
		dev-qt/qtcore:4
	)"
DEPEND="${RDEPEND}
	oss? ( virtual/os-headers )
	utils? ( sys-apps/help2man )"

REQUIRED_USE_A=(
	# at least one backend must be selected otherwise it segfaults
	"|| ( ${backends[*]} )"
	# IF(ALSOFT_UTILS AND NOT ALSOFT_NO_CONFIG_UTIL) add_subdirectory(utils/alsoft-config)
	"gui? ( utils )"
)

inherit arrays

# upstream uses this pre-created dir
BUILD_DIR="${S}/build"

src_prepare() {
	eapply "${FILESDIR}"/1.17.2-disable_pulseaudio_auto_spawn.patch

	# TODO: when some dependency is not found for examples/utils/tests, build doesn't die

	xdg_src_prepare
	cmake-utils_src_prepare
}

src_configure() {
		local mycmakeargs=(
			"-DALSOFT_BACKEND_ALSA=$(usex alsa)"
			"-DALSOFT_BACKEND_COREAUDIO=$(usex coreaudio)"
			"-DALSOFT_BACKEND_JACK=$(usex jack)"
			"-DALSOFT_BACKEND_OSS=$(usex oss)"
			"-DALSOFT_BACKEND_PORTAUDIO=$(usex portaudio)"
			"-DALSOFT_BACKEND_PULSEAUDIO=$(usex pulseaudio)"
			"-DALSOFT_BACKEND_WAVE=ON" # Wave File Writer

			"-DALSOFT_CPUEXT_SSE=$(usex cpu_flags_x86_sse)"
			"-DALSOFT_CPUEXT_SSE2=$(usex cpu_flags_x86_sse2)"
			"-DALSOFT_CPUEXT_SSE3=$(usex cpu_flags_x86_sse3)"
			"-DALSOFT_CPUEXT_SSE4_1=$(usex cpu_flags_x86_sse4_1)"
			"-DALSOFT_CPUEXT_NEON=$(usex neon)"

			"-DALSOFT_EXAMPLES=$(usex examples)"
			"-DALSOFT_INSTALL=ON"
			# Disable building the alsoft-config utility
			"-DALSOFT_NO_CONFIG_UTIL=$(usex '!gui')"
			"-DALSOFT_TESTS=$(usex tests)"
			# Build and install utility programs
			"-DALSOFT_UTILS=$(usex utils)"
		)

		cmake-utils_src_configure
}

H2M_BINS=( )

src_compile() {
	cmake-utils_src_compile

	use tests && H2M_BINS+=( altonegen )
	use utils && H2M_BINS+=( makehrtf openal-info )

	local h2m_opts=(
		--no-discard-stderr
		--no-info
		--version-string=${PV}
	)

	local b
	for b in "${H2M_BINS[@]}" ; do
		set -- help2man "${h2m_opts[@]}" --output=${b}.1 build/${b}
		echo "$@"
		"$@" || die
	done
}

src_install() {
	DOCS=( alsoftrc.sample env-vars.txt hrtf.txt ChangeLog README )

	cmake-utils_src_install

	(( ${#H2M_BINS[*]} )) && doman "${H2M_BINS[@]/%/.1}"

	# NOTE: alsoft.conf doesn't support PREFIX, needs patching in ${S}/Alc/alcConfig.c
	insinto /etc/openal
	newins alsoftrc.sample alsoft.conf

	if use gui ; then
		make_desktop_entry \
			"${EPREFIX}"/usr/bin/alsoft-config \
			"OpenAL Soft Configuration" \
			settings-configure \
			"Settings;HardwareSettings;Audio;AudioVideo;"
	fi
}
