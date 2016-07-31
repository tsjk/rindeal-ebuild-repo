# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE='threads(+),xml(+)'

inherit python-single-r1 waf-utils multilib-minimal linux-info systemd eutils

DESCRIPTION="Samba Suite Version 4"
HOMEPAGE="http://www.samba.org/"
LICENSE="GPL-3"

SLOT="0"
SRC_URI="mirror://samba/stable/${P}.tar.gz"

KEYWORDS="~amd64 ~arm"
IUSE="acl addc addns ads avahi client cluster cups dmapi fam gnutls iprint
	ldap pam quota selinux syslog +system-mitkrb5 systemd test winbind"

# sys-apps/attr is an automagic dependency (see bug #489748)
CDEPEND="${PYTHON_DEPS}
	>=app-arch/libarchive-3.1.2
	dev-lang/perl:=
	dev-libs/libbsd
	dev-libs/iniparser:0
	dev-libs/popt
	sys-libs/readline:=
	virtual/libiconv
	dev-python/subunit[${PYTHON_USEDEP}]
	sys-apps/attr
	sys-libs/libcap
	>=sys-libs/ldb-1.1.26
	sys-libs/ncurses:0=
	>=sys-libs/talloc-2.1.6[python,${PYTHON_USEDEP}]
	>=sys-libs/tdb-1.3.8[python,${PYTHON_USEDEP}]
	>=sys-libs/tevent-0.9.28
	sys-libs/zlib
	pam? ( virtual/pam )
	acl? ( virtual/acl )
	addns? ( net-dns/bind-tools[gssapi] )
	cluster? ( !dev-db/ctdb )
	cups? ( net-print/cups )
	dmapi? ( sys-apps/dmapi )
	fam? ( virtual/fam )
	gnutls? ( dev-libs/libgcrypt:0
		>=net-libs/gnutls-1.4.0 )
	ldap? ( net-nds/openldap )
	system-mitkrb5? ( app-crypt/mit-krb5 )
	!system-mitkrb5? ( >=app-crypt/heimdal-1.5[-ssl] )
	systemd? ( sys-apps/systemd:0= )"
DEPEND="${CDEPEND}
	virtual/pkgconfig"
RDEPEND="${CDEPEND}
	client? ( net-fs/cifs-utils[ads?] )
	selinux? ( sec-policy/selinux-samba )
	!dev-perl/Parse-Yapp
"

REQUIRED_USE="addc? ( gnutls !system-mitkrb5 )
	ads? ( acl gnutls ldap )
	${PYTHON_REQUIRED_USE}"



CONFDIR="${FILESDIR}/$(get_version_component_range 1-2)"

WAF_BINARY="${S}/buildtools/bin/waf"

# --with-shared-modules
SHARED_MODULES=()

pkg_setup() {
	python-single-r1_pkg_setup
	if use cluster ; then
		SHARED_MODULES+=( idmap_rid idmap_tdb2 $(usex ads idmap_ad '') )
	fi
}

src_prepare() {
	PATCHES=(
		"${FILESDIR}/${PN}-4.2.3-heimdal_compilefix.patch"
		"${FILESDIR}/${PN}-4.4.0-pam.patch" )
	default
}

multilib_src_configure() {
	local myconf=()
	myconf=(
		--enable-fhs
		--sysconfdir="${EPREFIX}/etc"
		--localstatedir="${EPREFIX}/var"
		--with-modulesdir="${EPREFIX}/usr/$(get_libdir)/samba"
		--with-piddir="${EPREFIX}/run/${PN}"
		--bundled-libraries=NONE
		--builtin-libraries=NONE
		--disable-rpath
		--disable-rpath-install
		--nopyc
		--nopyo

		$(use_with acl acl-support)
		$(use_with addc ad-dc)
		$(use_with addns dnsupdate)
		$(use_with ads)
		$(use_enable avahi)
		$(use_with cluster cluster-support)
		$(use_enable cups)
		$(use_with dmapi)
		$(use_with fam)
		$(use_enable gnutls)
		$(use_enable iprint)
		$(use_with ldap)
		$(use_with pam)
		$(usex pam "--with-pammodulesdir=${EPREFIX}/$(get_libdir)/security" '')
		$(use_with quota quotas)
		$(use_with syslog)
		$(use_with systemd)
		$(use_with system-mitkrb5)
		$(use_with winbind)
		$(usex test '--enable-selftest' '')
		--with-shared-modules="(IFS=,; echo "${SHARED_MODULES[*]}")"
	)

	CPPFLAGS="-I${SYSROOT}${EPREFIX}/usr/include/et ${CPPFLAGS}" \
		waf-utils_src_configure ${myconf[@]}
}

multilib_src_install() {
	waf-utils_src_install

	# Make all .so files executable
	find "${D}" -type f -name "*.so" -exec chmod +x {} +

	if multilib_is_native_abi; then
		# install ldap schema for server (bug #491002)
		if use ldap ; then
			insinto /etc/openldap/schema
			doins examples/LDAP/samba.schema
		fi

		# create symlink for cups (bug #552310)
		if use cups ; then
			dosym /usr/bin/smbspool /usr/libexec/cups/backend/smb
		fi

		# install example config file
		insinto /etc/samba
		doins examples/smb.conf.default

		# Install init script and conf.d file
		newinitd "${CONFDIR}/samba4.initd-r1" samba
		newconfd "${CONFDIR}/samba4.confd" samba

		systemd_dotmpfilesd "${FILESDIR}"/samba.conf
		systemd_dounit "${FILESDIR}"/nmbd.service
		systemd_dounit "${FILESDIR}"/smbd.{service,socket}
		systemd_newunit "${FILESDIR}"/smbd_at.service 'smbd@.service'
		systemd_dounit "${FILESDIR}"/winbindd.service
		systemd_dounit "${FILESDIR}"/samba.service
	fi
}

multilib_src_test() {
	if multilib_is_native_abi ; then
		"${WAF_BINARY}" test || die "test failed"
	fi
}

pkg_postinst() {
	ewarn "Be aware the this release contains the best of all of Samba's"
	ewarn "technology parts, both a file server (that you can reasonably expect"
	ewarn "to upgrade existing Samba 3.x releases to) and the AD domain"
	ewarn "controller work previously known as 'samba4'."

	elog "For further information and migration steps make sure to read "
	elog "http://samba.org/samba/history/${P}.html "
	elog "http://samba.org/samba/history/${PN}-4.2.0.html and"
	elog "http://wiki.samba.org/index.php/Samba4/HOWTO "
}
