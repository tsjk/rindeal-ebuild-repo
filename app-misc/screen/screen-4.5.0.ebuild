# Copyright 1999-2016 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# functions: eautoreconf
inherit autotools
inherit eutils
# functions: append-cppflags
inherit flag-o-matic
# functions: pamd_mimic_system
inherit pam
inherit toolchain-funcs
# functions: enewgroup
inherit user

DESCRIPTION="Window manager that multiplexes a physical terminal between processes (shells)"
HOMEPAGE="https://www.gnu.org/software/screen/"
LICENSE="GPL-2"

SLOT="0"
SRC_URI="http://git.savannah.gnu.org/cgit/${PN}.git/snapshot/v.${PV}.tar.gz"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE="debug nethack pam selinux multiuser"

CDEPEND="
	>=sys-libs/ncurses-5.2:0=
	pam? ( virtual/pam )"
RDEPEND="${CDEPEND}
	selinux? ( sec-policy/selinux-screen )"
DEPEND="${CDEPEND}
	sys-apps/texinfo"

pkg_setup() {
	# Make sure utmp group exists, as it's used later on.
	enewgroup utmp 406
}

src_prepare() {
	# - Don't use utempter even if it is found on the system.
	eapply "${FILESDIR}"/${PN}-4.3.0-no-utempter.patch
	eapply_user

	# sched.h is a system header and causes problems with some C libraries
	mv sched.h _sched.h || die
	sed -i '/include/ s:sched.h:_sched.h:' screen.h || die

	# Fix manpage.
	sed -i \
		-e "s:/usr/local/etc/screenrc:${EPREFIX}/etc/screenrc:g" \
		-e "s:/usr/local/screens:${EPREFIX}/tmp/screen:g" \
		-e "s:/local/etc/screenrc:${EPREFIX}/etc/screenrc:g" \
		-e "s:/etc/utmp:${EPREFIX}/var/run/utmp:g" \
		-e "s:/local/screens/S\\\-:${EPREFIX}/tmp/screen/S\\\-:g" \
		doc/screen.1 \
		|| die

	# reconfigure
	eautoreconf
}

src_configure() {
	append-cppflags "-DMAXWIN=${MAX_SCREEN_WINDOWS:-100}"

	use nethack || append-cppflags "-DNONETHACK"
	use debug && append-cppflags "-DDEBUG"

	local econf_args=(
		--with-socket-dir="${EPREFIX}/tmp/screen"
		--with-sys-screenrc="${EPREFIX}/etc/screenrc"
		--with-pty-mode=0620
		--with-pty-group=5
		--enable-rxvt_osc
		--enable-telnet
		--enable-colors256
		$(use_enable pam)
	)
	econf "${econf_args[@]}"
}

src_compile() {
	emake comm.h term.h
	emake osdef.h
	emake -C doc screen.info

	default
}

src_install() {
	local tmpfiles_perms tmpfiles_group

	dobin screen

	if use multiuser || use prefix
	then
		fperms 4755 /usr/bin/screen
		tmpfiles_perms="0755"
		tmpfiles_group="root"
	else
		fowners root:utmp /usr/bin/screen
		fperms 2755 /usr/bin/screen
		tmpfiles_perms="0775"
		tmpfiles_group="utmp"
	fi

	dodir /etc/tmpfiles.d
	echo "d /tmp/screen ${tmpfiles_perms} root ${tmpfiles_group}" \
		> "${ED}"/etc/tmpfiles.d/screen.conf

	insinto /usr/share/screen
	doins terminfo/{screencap,screeninfo.src}
	insinto /usr/share/screen/utf8encodings
	doins utf8encodings/??
	insinto /etc
	doins "${FILESDIR}"/screenrc

	pamd_mimic_system screen auth

	dodoc \
		README ChangeLog INSTALL TODO NEWS* patchlevel.h \
		doc/{FAQ,README.DOTSCREEN,fdpat.ps,window_to_display.ps}

	doman doc/screen.1
	doinfo doc/screen.info
}

pkg_postinst() {
	if [[ -z ${REPLACING_VERSIONS} ]]
	then
		elog "Some dangerous key bindings have been removed or changed to more safe values."
		elog "We enable some xterm hacks in our default screenrc, which might break some"
		elog "applications. Please check /etc/screenrc for information on these changes."
	fi

	# Add /tmp/screen in case it doesn't exist yet. This should solve
	# problems like bug #508634 where tmpfiles.d isn't in effect.
	local rundir="${EROOT%/}/tmp/screen"
	if [[ ! -d ${rundir} ]] ; then
		if use multiuser || use prefix ; then
			tmpfiles_group="root"
		else
			tmpfiles_group="utmp"
		fi
		mkdir -m 0775 "${rundir}"
		chgrp ${tmpfiles_group} "${rundir}"
	fi

	ewarn "This revision changes the screen socket location to ${rundir}"
}
