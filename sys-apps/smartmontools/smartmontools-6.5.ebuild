# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

inherit flag-o-matic autotools systemd

DESCRIPTION="Control and monitor storage systems using S.M.A.R.T."
HOMEPAGE="https://www.smartmontools.org"
LICENSE="GPL-2"

SLOT="0"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

KEYWORDS="~amd64 ~arm"
IUSE="caps examples minimal selinux static update_drivedb"

CDEPEND_A=(
	"caps? ("
		"static? ( sys-libs/libcap-ng[static-libs] )"
		"!static? ( sys-libs/libcap-ng )"
	")"
	"selinux? ("
		"sys-libs/libselinux"
	")"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	"!minimal? ( virtual/mailx )"
	"selinux? ( sec-policy/selinux-smartmon )"
)

inherit arrays

src_prepare() {
	default

	[[ ${PV} == "9999" ]] && \
		eautoreconf
}

MY_DB_PATH="/var/db/${PN}"

src_configure() {
	use minimal && einfo "Skipping the monitoring daemon for minimal build."
	use static && append-ldflags -static

	local myeconfargs=(
		--docdir="${EPREFIX}/usr/share/doc/${PF}"
		--with-smartdscriptdir="${EPREFIX}/usr/libexec/${PN}"
		--with-drivedbdir="${EPREFIX}${MY_DB_PATH}" # gentoo#575292
		--without-initscriptdir
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)"

		$(use_with caps libcap-ng)
		$(use_with selinux)
		$(use_with update_drivedb update-smart-drivedb)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	if use minimal ; then
		dosbin smartctl
		doman smartctl.8
	else
		default

		use examples || erm -r "${ED}"/usr/share/doc/${PF}/example*

		keepdir "${MY_DB_PATH}"
		if use update_drivedb ; then
			# Move drivedb.h file temporarily out of PM's sight (bug gentoo#575292)
			mv -v "${ED}""${MY_DB_PATH}/drivedb.h" "${T}" || die

			# TODO
			# ${PN}-update-drivedb
			# systemd_newunit oneshot_service
			# systemd_newunit timer
		fi
	fi

	erm -rf "${ED}/etc/init.d"
}

pkg_postinst() {
	if ! use minimal ; then
		if [[ -f "${EROOT}/${MY_DB_PATH}/drivedb.h" ]] ; then
			ewarn "WARNING! The drive database file has been replaced with the version that"
			ewarn "got shipped with this release of ${PN}. You may want to update the"
			ewarn "database by running the following command as root:"
			ewarn ""
			ewarn "    # ${EPREFIX}/usr/sbin/update-smart-drivedb"
		fi

		if use update_drivedb ; then
			# Move drivedb.h to /var/db/${PN} (bug gentoo#575292)
			mv -v "${T}"/drivedb.h "${MY_DB_PATH}" || die
		fi
	fi
}
