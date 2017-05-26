# Copyright 1999-2016 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:shadow-maint"

inherit git-hosting
inherit eutils
# functions: elibtoolize
inherit libtool
# functions: dopamd, newpamd
inherit pam
# functions: eautoreconf
inherit autotools

DESCRIPTION="Utilities to deal with user accounts"
HOMEPAGE="${GH_HOMEPAGE} http://pkg-shadow.alioth.debian.org/"
LICENSE="BSD GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=(
	nls rpath +man +largefile
	audit selinux
	acl libcrack pam skey xattr +account-tools-setuid subordinate-ids utmpx shadowgrp +sha-crypt +nscd
)

# Taken from the man/Makefile.am file.
L10N_LOCALES=( cs da de es fi fr hu id it ja ko pl pt_BR ru sv tr zh_CN zh_TW )
inherit l10n-r1

# TODO: review deps in configure.ac
CDEPEND_A=(
	"acl? ( sys-apps/acl:0= )"
	"audit? ( >=sys-process/audit-2.6:0= )"
	"libcrack? ( >=sys-libs/cracklib-2.7-r3:0= )"
	"pam? ( virtual/pam:0= )"
	"skey? ( sys-auth/skey:0= )"
	"selinux? ("
		">=sys-libs/libselinux-1.28:0="
		"sys-libs/libsemanage:0="
	")"
	"nls? ( virtual/libintl )"
	"xattr? ( sys-apps/attr:0= )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"app-arch/xz-utils"
	"nls? ( sys-devel/gettext )"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"pam? ( >=sys-auth/pambase-20150213 )"
)

REQUIRED_USE_A=(
	"account-tools-setuid? ( pam )"
)

inherit arrays

src_prepare() {
	eapply "${FILESDIR}"/4.1.3-dots-in-usernames.patch
	eapply "${FILESDIR}"/4.4-prototypes.patch
	eapply "${FILESDIR}"/4.4-load_defaults.patch
	eapply_user

	# TODO: L10N

	if ! use man ; then
		sed -e '/^SUBDIRS/ s| man | |' -i -- Makefile.am || die
	fi

	eautoreconf
	elibtoolize
}

src_configure() {
	local my_econf_args=(
		--enable-shared=yes
		--enable-static=yes

		--without-tcb # unsupported by upstream and actually by everything
		# HP-UX 10 limits to 16 characters, so 64 should be pretty safe, unlimited is too dangerous
		--with-group-name-max-length=64

		$(use_enable shadowgrp)
		$(use_enable man)
		$(use_enable account-tools-setuid)
		$(use_enable utmpx)
		$(use_enable subordinate-ids)
		$(use_enable nls)
		$(use_enable rpath)
		$(use_enable largefile)

		$(use_with audit)
		$(use_with pam libpam)
		$(use_with selinux)
		$(use_with acl)
		$(use_with xattr attr)
		$(use_with skey)

		$(use_with libcrack)
		$(use_with sha-crypt)
		$(use_with nscd)
	)
	econf "${my_econf_args[@]}"
}

set_login_opt() {
	local comment="" opt=$1 val=$2
	if [[ -z ${val} ]]; then
		comment="#"
		sed -i \
			-e "/^${opt}\>/s:^:#:" \
			"${ED}"/etc/login.defs || die
	else
		sed -i -r \
			-e "/^#?${opt}\>/s:.*:${opt} ${val}:" \
			"${ED}"/etc/login.defs
	fi
	local res=$(grep "^${comment}${opt}\>" "${ED}"/etc/login.defs)
	einfo "${res:-Unable to find ${opt} in /etc/login.defs}"
}

src_install() {
	emake DESTDIR="${D}" suidperms=4711 install

	if ! use pam ; then
		insinto /etc
		insopts -m0600
		doins etc/login.access etc/limits
	fi

	# needed for 'useradd -D'
	insinto /etc/default
	insopts -m0600
	doins "${FILESDIR}"/default/useradd

	# move passwd to / to help recover broke systems #64441
	emv "${ED}"/usr/bin/passwd "${ED}"/bin/
	dosym /bin/passwd /usr/bin/passwd

	insinto /etc
	insopts -m0644
	newins etc/login.defs login.defs

	set_login_opt CREATE_HOME yes
	if ! use pam ; then
		set_login_opt MAIL_CHECK_ENAB no
		set_login_opt SU_WHEEL_ONLY yes
		set_login_opt CRACKLIB_DICTPATH /usr/$(get_libdir)/cracklib_dict
		set_login_opt LOGIN_RETRIES 3
		set_login_opt ENCRYPT_METHOD SHA512
		set_login_opt CONSOLE
	else
		dopamd "${FILESDIR}"/pam.d-include/shadow

		local x
		for x in chpasswd chgpasswd newusers ; do
			newpamd "${FILESDIR}"/pam.d-include/passwd ${x}
		done
		for x in chage chsh chfn user{add,del,mod} group{add,del,mod} ; do
			newpamd "${FILESDIR}"/pam.d-include/shadow ${x}
		done

		# comment out login.defs options that pam hates
		local sed_args=() opt opts=(
			CHFN_AUTH
			CONSOLE
			CRACKLIB_DICTPATH
			ENV_HZ
			ENVIRON_FILE
			FAILLOG_ENAB
			FTMP_FILE
			LASTLOG_ENAB
			MAIL_CHECK_ENAB
			MOTD_FILE
			NOLOGINS_FILE
			OBSCURE_CHECKS_ENAB
			PASS_ALWAYS_WARN
			PASS_CHANGE_TRIES
			PASS_MIN_LEN
			PORTTIME_CHECKS_ENAB
			QUOTAS_ENAB
			SU_WHEEL_ONLY
		)
		for opt in "${opts[@]}" ; do
			set_login_opt ${opt}
			sed_args+=( -e "/^#${opt}\>/b pamnote" )
		done
		sed "${sed_args[@]}" \
			-e 'b exit' \
			-e ': pamnote; i# NOTE: This setting should be configured via /etc/pam.d/ and not in this file.' \
			-e ': exit' \
			-i -- "${ED}"/etc/login.defs || die

		if use man ; then
			# remove manpages that pam will install for us
			# and/or don't apply when using pam
			erm -f "${ED}"/usr/share/man/man5/suauth.5
			erm -f "${ED}"/usr/share/man/man5/limits.5
		fi

		# Remove pam.d files provided by sys-auth/pambase
		erm "${ED}"/etc/pam.d/{login,passwd,su}
	fi

	if use man ; then
		# Remove manpages that are handled by other packages (sys-apps/coreutils sys-apps/man-pages)
		erm -f "${ED}"/usr/share/man/man1/id.1
		erm -f "${ED}"/usr/share/man/man5/passwd.5
		erm -f "${ED}"/usr/share/man/man3/getspnam.3
	fi

	dodoc ChangeLog NEWS TODO doc/{HOWTO,README*,WISHLIST,*.txt}
	newdoc README README.download
}

pkg_preinst() {
	erm "${EROOT}"/etc/pam.d/system-auth.new \
		"${EROOT}/etc/login.defs.new"
}

pkg_postinst() {
	# Enable shadow groups.
	if [[ ! -f "${EROOT}"/etc/gshadow ]] ; then
		if grpck -r -R "${EROOT}" 2>/dev/null ; then
			grpconv -R "${EROOT}"
		else
			ewarn "Running 'grpck' returned errors.  Please run it by hand, and then"
			ewarn "run 'grpconv' afterwards!"
		fi
	fi

	einfo "The 'adduser' symlink to 'useradd' has been dropped."
}
