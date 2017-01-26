# Copyright 1999-2016 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2



##
## TODO: ~copy http://pkgs.fedoraproject.org/cgit/rpms/screen.git/tree/screen.spec
##



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
	sed -e '/include/ s:sched.h:_sched.h:' -i -- screen.h || die

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
	dobin "${PN}"

	dodoc \
		README ChangeLog INSTALL TODO NEWS* patchlevel.h \
		doc/{FAQ,README.DOTSCREEN,fdpat.ps,window_to_display.ps}

	doman	"doc/${PN}.1"
	doinfo	"doc/${PN}.info"

	insinto /usr/share/screen
	doins terminfo/{screencap,screeninfo.src}
	insinto /usr/share/screen/utf8encodings
	doins utf8encodings/??

	# default settings
	insinto /etc
	doins "${FILESDIR}"/screenrc

	# FIXME: ??
	pamd_mimic_system screen auth

	src_install_tmpfiles
}

src_install_tmpfiles() {
	declare -gr -- SCREEN_RUNDIR="${EROOT%/}/tmp/screen"
	screen_rundir_perms= screen_rundir_group=

	if use multiuser || use prefix
	then
		fperms 4755 "/usr/bin/${PN}"
		screen_rundir_perms="0755"
		screen_rundir_group="root"
	else
		fowners root:utmp "/usr/bin/${PN}"
		fperms 2755 "/usr/bin/${PN}"
		screen_rundir_perms="0775"
		screen_rundir_group="utmp"
	fi

	readonly screen_rundir_perms screen_rundir_group

	dodir /etc/tmpfiles.d
	echo "d ${SCREEN_RUNDIR} ${screen_rundir_perms} root ${screen_rundir_group}" \
		> "${ED}"/etc/tmpfiles.d/screen.conf
}

pkg_postinst() {
	# Add ${SCREEN_RUNDIR} in case it doesn't exist yet. This should solve
	# problems like bug #508634 where tmpfiles.d isn't in effect.
	if [[ ! -d "${rundir}" ]] ; then
		mkdir -m ${screen_rundir_perms} "${SCREEN_RUNDIR}" || die
		chgrp ${screen_rundir_group} "${SCREEN_RUNDIR}" || die
	fi
}
