# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass
GH_RN="github:Motion-Project"
[[ "${PV}" == *9999* ]] || GH_REF="release-${PV}"

inherit git-hosting
# EXPORT_FUNCTIONS src_prepare src_configure src_compile src_test src_install
inherit cmake-utils
inherit readme.gentoo-r1
inherit user
inherit systemd

DESCRIPTION="A software motion detector"
HOMEPAGE="https://motion-project.github.io ${GH_HOMEPAGE}"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( ffmpeg mmal mysql postgres v4l2 jpeg webp sqlite3 sdl )

CDEPEND_A=(
	"ffmpeg? ("
		"media-video/ffmpeg:0="
	")"
	"jpeg? ( virtual/jpeg:= )"
	"mmal? ( media-libs/raspberrypi-userland )"
	"mysql? ( virtual/mysql )"
	"postgres? ( dev-db/postgresql:= )"
	"webp? ( media-libs/libwebp )"
	"sqlite3? ( dev-db/sqlite:3 )"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

DISABLE_AUTOFORMATTING="yes"
DOC_CONTENTS="
You need to setup /etc/${PN}/${PN}.conf before running ${PN} for
the first time. You can use /etc/${PN}/${PN}-dist.conf as a template.
Please note that the 'daemon' and 'process_id_file' settings are
overridden by the bundled OpenRC init script and systemd unit where
appropriate.

To install ${PN} as a service, use:
rc-update add ${PN} default # with OpenRC
systemctl enable ${PN}.service # with systemd
"

pkg_setup() {
	enewuser ${PN} -1 -1 -1 video
}

src_prepare() {
	eapply_user

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DWITH_FFMPEG=$(usex ffmpeg)
		-DWITH_MMAL=$(usex mmal)
		-DWITH_MYSQL=$(usex mysql)
		-DWITH_PGSQL=$(usex postgres)
		-DWITH_PTHREAD=no
		-DWITH_SDL=$(usex sdl)
		-DWITH_SQLITE3=$(usex sqlite3)
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	newinitd "${FILESDIR}"/${PN}.initd-r3 ${PN}
	newconfd "${FILESDIR}"/${PN}.confd-r1 ${PN}

	systemd_dounit "${FILESDIR}"/${PN}.service
	systemd_dounit "${FILESDIR}"/${PN}_at.service
	systemd_dotmpfilesd "${FILESDIR}"/${PN}.conf

	keepdir /var/lib/motion
	fowners motion:video /var/lib/motion
	fperms 0750 /var/lib/motion

	readme.gentoo_create_doc
	readme.gentoo_print_elog
}
