# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_URI="github"

inherit flag-o-matic git-hosting autotools systemd

DESCRIPTION="Rotates, compresses, and mails system logs"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm"
IUSE="acl cron selinux systemd"

CDEPEND="
	>=dev-libs/popt-1.5
	acl? ( virtual/acl )
	selinux? ( sys-libs/libselinux )
"
DEPEND="${CDEPEND}"
RDEPEND="${CDEPEND}
	cron? ( virtual/cron )
	selinux? ( sec-policy/selinux-logrotate )
"
REQUIRED_USE="?? ( cron systemd )"

# https://bugs.gentoo.org/show_bug.cgi?id=357275
STATEFILE="${EPREFIX}/var/lib/${PN}/${PN}.status"

src_prepare() {
	PATCHES=(
		"${FILESDIR}"/3.9.2-configure_ac_lfs.patch
		"${FILESDIR}"/3.9.2-ignore_hidden_files_in_conf_dir.patch
		"${FILESDIR}"/3.11.0-manpage_config_clarification.patch
	)
	default

	sed -e '/CFLAGS =/ s|-Werror||' -i -- Makefile.am || die

	# https://bugs.gentoo.org/show_bug.cgi?id=357275
	sed -e "s|/var/lib/logrotate.status|${STATEFILE}|" \
		-i -- ${PN}.8.in config.h || die

	# prevent these from installing
	rm -v -f README.{HPUX,Solaris} || die

	eautoreconf
}

src_configure() {
	local econf_args=(
		$(use_with acl)
		$(use_with selinux)
	)
	econf "${econf_args[@]}"
}

src_install() {
	default

	keepdir "${STATEFILE%/*}"

	insinto /etc
	doins "${FILESDIR}"/${PN}.conf
	keepdir /etc/${PN}.d

	if use cron ; then
		exeinto /etc/cron.daily
		newexe "${FILESDIR}"/${PN}.cron ${PN}
	elif use systemd ; then
		systemd_dounit "${FILESDIR}"/${PN}.service
		systemd_dounit "${FILESDIR}"/${PN}.timer
	fi
}

pkg_postinst() {
	if use systemd && [ -f "${EROOT}"/etc/cron.daily/${PN} ] ; then
		ewarn "You have systemd enabled and cron job installed at the same time."
		ewarn "This setup may cause problems. You have been warned."
	fi
}
