# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_URI="github/karelzak"
[[ "${PV}" != *9999* ]] && \
	GH_FETCH_TYPE="manual"

PYTHON_COMPAT=( python{2_7,3_{3,4,5}} )

# functions: rindeal:dsf:eval
inherit rindeal-utils
# functions: git-hosting_unpack
inherit git-hosting
# TODO: make it python-r1
inherit python-single-r1
# functions: eautoreconf
inherit autotools
# functions: elibtoolize
inherit libtool
# functions: get_bashcompdir
inherit bash-completion-r1
# functions: systemd_get_systemunitdir
inherit systemd
# functions: prune_libtool_files
inherit eutils
# functions: gen_usr_ldscript
inherit toolchain-funcs

DESCRIPTION="Various useful system utilities for Linux"
HOMEPAGE="https://www.kernel.org/pub/linux/utils/${PN}/ ${GH_HOMEPAGE}"
LICENSE="GPL-2 LGPL-2.1 BSD-4 MIT public-domain"

SLOT="0"
distfile="${P}--snapshot.tar.bz2"
SRC_URI="https://git.kernel.org/cgit/utils/util-linux/util-linux.git/snapshot/v${PV}.tar.bz2 -> ${distfile}"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=(
	doc libpython test nls static-libs +assert +symvers +largefile rpath +unicode

	# TODO: categorize these
	+suid selinux audit +udev +ncurses systemd +pam

	+libblkid
	+libfdisk
	+libmount libmount-support-mtab
	+libsmartcols
	+libuuid libuuid-force-uuidd

	+agetty
	bfs
	cal
	chfn-chsh chfn-chsh-password +chsh-only-listed
	cramfs
	eject
	+fallocate
	fdformat
	+fsck
	+hwclock
	ipcrm
	ipcs
	+kill
	last
	line
	+logger
	login login-chown-vcs login-stat-mail
	+losetup
	lslogins
	mesg
	minix
	+more
	+mount
	+mountpoint
	newgrp
	nologin
	+nsenter
	+partx
	pg pg-bell
	pivot_root
	+raw
	+rename
	reset
	+runuser
	+schedutils
	+setpriv
	+setterm
	su
	sulogin
	switch_root
	tunelp
	ul
	+unshare
	utmpdump
	vipw
	wall
	+wdctl
	write
	zramctl

	uuidd
	pylibmount

	+colors-default
	plymouth-support
	sulogin-emergency-mount
	use-tty-group
	usrdir-path

	btrfs
	+cap-ng
	+libz
	+readline
	slang
	smack
	tinfo
	user
	utempter
	+util
)

CDEPEND_A=(
	# `PKG_CHECK_MODULES([SELINUX], [libselinux >= 2.0],`
	"selinux? ( >=sys-libs/libselinux-2.0 )"
	# `UL_CHECK_LIB([audit]`
	"audit? ( sys-process/audit )"
	# `UL_CHECK_LIB([udev]`
	"udev?	( virtual/libudev:= )"

	# `UL_NCURSES_CHECK([ncursesw])`
	# `UL_NCURSES_CHECK([ncurses])`
	"ncurses? ( >=sys-libs/ncurses-5.2-r2:0=[unicode?] )"
	# `AC_CHECK_HEADERS([slang.h slang/slang.h])`
	# `AC_CHECK_HEADERS([slcurses.h slang/slcurses.h],`
	"slang? ( sys-libs/slang )"
	# `PKG_CHECK_MODULES(TINFO, [tinfo],`
	"tinfo? ( sys-libs/ncurses:*[tinfo] )"
	# `UL_CHECK_LIB([readline], [readline])`
	"readline? ( sys-libs/readline:0= )"
	# `UL_CHECK_LIB([utempter], [utempter_add_record])`
	"utempter? ( sys-libs/libutempter:0 )"
	# `UL_CHECK_LIB([cap-ng], [capng_apply], [cap_ng])`
	"cap-ng? ( sys-libs/libcap-ng )"
	# `AC_CHECK_LIB([z], [crc32]`
	"libz? ( sys-libs/zlib )"
	# `PKG_CHECK_MODULES(LIBUSER,[libuser >= 0.58]`
	"user? ( sys-libs/libuser )"
	# `AS_CASE([$with_btrfs:$have_linux_btrfs_h],`
	"btrfs? ( sys-fs/btrfs-progs )"
	# `PKG_CHECK_MODULES([SYSTEMD], [libsystemd], [have_systemd=yes], [have_systemd=no])`
	"systemd? ( sys-apps/systemd )"
	"pam?		( sys-libs/pam )"
	"libpython?	( ${PYTHON_DEPS} )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
	"nls?	( sys-devel/gettext )"
	"test?	( sys-devel/bc )"
	"sys-kernel/linux-headers:0"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"kill? ("
		"!sys-apps/coreutils[kill]"
		"!sys-process/procps[kill]"
	")"
	"schedutils? ( !sys-process/schedutils )"
	"eject? ( !sys-block/eject )"
	"!<app-shells/bash-completion-2.3-r2"
	"$(rindeal:dsf:eval \
		'chfn-chsh|login|su|vipw|nologin|newgrp' \
			'!sys-apps/shadow' )"
	"reset? ( !sys-libs/ncurses )"
)

REQUIRED_USE_A=(
	"libpython? ( ${PYTHON_REQUIRED_USE} )"
	# curses lib is selected via `CURSES_LIB_NAME`, which can be one of:
	#     ncurses ncursesw slang
	"^^ ( ncurses slang )"
	# `UL_REQUIRES_BUILD([libfdisk], [libuuid])`
	"libfdisk? ( libuuid )"
	# `UL_REQUIRES_BUILD([libmount], [libblkid])`
	"libmount? ( libblkid )"
	# `UL_REQUIRES_BUILD([fdisk], [libfdisk])`
	# `UL_REQUIRES_BUILD([fdisk], [libsmartcols])`
	# `UL_REQUIRES_BUILD([sfdisk], [libfdisk])`
	# `UL_REQUIRES_BUILD([sfdisk], [libsmartcols])`
	# `UL_REQUIRES_BUILD([cfdisk], [libfdisk])`
	# `UL_REQUIRES_BUILD([cfdisk], [libsmartcols])`
	# TODO
	# `UL_REQUIRES_BUILD([mount], [libmount])`
	"mount? ( libmount )"
	# `UL_REQUIRES_BUILD([losetup], [libsmartcols])`
	"losetup? ( libsmartcols )"
	# `UL_REQUIRES_BUILD([zramctl], [libsmartcols])`
	"zramctl? ( libsmartcols )"
	# `UL_REQUIRES_BUILD([fsck], [libmount])`
	"fsck? ( libmount )"
	# `UL_REQUIRES_BUILD([partx], [libblkid])`
	# `UL_REQUIRES_BUILD([partx], [libsmartcols])`
	"partx? ( libblkid libsmartcols )"
	# `UL_REQUIRES_BUILD([uuidd], [libuuid])`
	"uuidd? ( libuuid )"
	# `UL_REQUIRES_BUILD([uuidgen], [libuuid])`
	# `UL_REQUIRES_BUILD([blkid], [libblkid])`
	# `UL_REQUIRES_BUILD([findfs], [libblkid])`
	# `UL_REQUIRES_BUILD([wipefs], [libblkid])`
	# `UL_REQUIRES_BUILD([findmnt], [libmount])`
	# `UL_REQUIRES_BUILD([findmnt], [libblkid])`
	# `UL_REQUIRES_BUILD([findmnt], [libsmartcols])`
	# TODO
	# `UL_REQUIRES_BUILD([mountpoint], [libmount])`
	"mountpoint? ( libmount )"
	# `UL_REQUIRES_HAVE([setpriv], [cap_ng], [libcap-ng library])`
	"setpriv? ( cap-ng )"
	# `UL_REQUIRES_BUILD([eject], [libmount])`
	"eject? ( libmount )"
	# `UL_REQUIRES_HAVE([cramfs], [z], [z library])`
	"cramfs? ( libz )"
	# `UL_REQUIRES_BUILD([fstrim], [libmount])`
	# `UL_REQUIRES_BUILD([swapon], [libblkid])`
	# `UL_REQUIRES_BUILD([swapon], [libmount])`
	# `UL_REQUIRES_BUILD([swapon], [libsmartcols])`
	# `UL_REQUIRES_BUILD([lsblk], [libblkid])`
	# `UL_REQUIRES_BUILD([lsblk], [libmount])`
	# `UL_REQUIRES_BUILD([lsblk], [libsmartcols])`
	# `UL_REQUIRES_BUILD([lscpu], [libsmartcols])`
	# TODO
	# `UL_REQUIRES_BUILD([lslogins], [libsmartcols])`
	"lslogins? ( libsmartcols )"
	# `UL_REQUIRES_BUILD([wdctl], [libsmartcols])`
	"wdctl? ( libsmartcols )"
	# `UL_REQUIRES_BUILD([swaplabel], [libblkid])`
	# `UL_REQUIRES_BUILD([prlimit], [libsmartcols])`
	# `UL_REQUIRES_BUILD([lslocks], [libmount])`
	# `UL_REQUIRES_BUILD([lslocks], [libsmartcols])`
	# `UL_REQUIRES_BUILD([lsipc], [libsmartcols])`
	# `UL_REQUIRES_BUILD([lsns], [libsmartcols])`
	# TODO
	# `UL_REQUIRES_HAVE([chfn_chsh], [security_pam_appl_h], [PAM header file])`
	"$(rindeal:dsf:eval 'chfn-chsh-password|user' 'pam')"
	# `UL_REQUIRES_HAVE([login], [security_pam_appl_h], [PAM header file])`
	"login? ( pam )"
	# `UL_REQUIRES_HAVE([su], [security_pam_appl_h], [PAM header file])`
	"su? ( pam )"
	# `UL_REQUIRES_HAVE([runuser], [security_pam_appl_h], [PAM header file])`
	"runuser? ( pam )"
	# `UL_REQUIRES_HAVE([ul], [ncursesw, tinfo, ncurses], [ncursesw, ncurses or tinfo libraries])`
	"ul? ( || ( ncurses tinfo ) )"
	# `UL_REQUIRES_HAVE([more], [ncursesw, tinfo, ncurses, termcap], [ncursesw, ncurses, tinfo or termcap libraries])`
	"more? ( || ( ncurses tinfo ) )"
	# `UL_REQUIRES_HAVE([pg], [ncursesw, ncurses], [ncursesw or ncurses library])`
	"pg? ( ncurses )"
	# `UL_REQUIRES_HAVE([setterm], [ncursesw, ncurses], [ncursesw or ncurses library])`
	"setterm? ( ncurses )"
	# `UL_REQUIRES_BUILD([ionice], [schedutils])`
	# `UL_REQUIRES_BUILD([taskset], [schedutils])`
	# `UL_REQUIRES_BUILD([chrt], [schedutils])`
	# TODO
	# `UL_REQUIRES_HAVE([pylibmount], [libpython], [libpython])`
	# `UL_REQUIRES_BUILD([pylibmount], [libmount])`
	"pylibmount? ( libpython libmount )"
)

inherit arrays

L10N_LOCALES=( ca cs da de es et eu fi fr gl hr hu id it ja nl pl pt_BR ru sl sv tr uk vi zh_CN zh_TW )
inherit l10n-r1

src_unpack() {
	git-hosting_unpack "${DISTDIR}/${distfile}" "${S}"
	default
}

pkg_setup() {
	use libpython && python-single-r1_pkg_setup
}

src_prepare-locales() {
	local l locales dir="po" pre="lang_" post=".po"

	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"

	l10n_get_locales locales app off
	for l in ${locales} ; do
		erm "${dir}/${pre}${l}${post}"
	done
}

src_prepare() {
	eapply_user

	if use nls ; then
		src_prepare-locales
	else
		erm po/*.po
	fi
	# this allows ./configure to generate Makefile
	./po/update-potfiles || die

	eautoreconf
	elibtoolize
}

src_configure() {
	export ac_cv_header_security_pam_misc_h="$(usex pam)" # gentoo#485486
	export ac_cv_header_security_pam_appl_h="$(usex pam)" # gentoo#545042

	local my_econf_args=(
		--enable-fs-paths-extra="${EPREFIX}/usr/sbin:${EPREFIX}/bin:${EPREFIX}/usr/bin"
		--docdir='${datarootdir}'/doc/${PF}

		## BASH completion
		--with-bashcompletiondir="$(get_bashcompdir)"
		--enable-bash-completion
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)"

		# prevent leaks
		--disable-all-programs

		## TODO: reorganize these options according to ./configure --help

		$(tc-has-tls || echo --disable-tls)	# disable use of thread local support

		$(use_enable doc gtk-doc)	# use gtk-doc to build documentation
		$(use_enable assert)
		$(use_enable symvers)
		$(use_enable largefile)
		$(use_enable nls)
		$(use_enable rpath)
		$(use_enable static-libs static)

		$(use_enable unicode widechar) # compile wide character support

		$(use_enable libuuid)
		$(use_enable libuuid-force-uuidd)
		$(use_enable libblkid)
		$(use_enable libmount)
		$(use_enable libmount-support-mtab)
		$(use_enable libsmartcols)
		$(use_enable libfdisk)
		$(use_enable mount)
		$(use_enable losetup)
		$(use_enable zramctl)
		$(use_enable fsck)
		$(use_enable partx)
		$(use_enable uuidd)
		$(use_enable mountpoint)
		$(use_enable fallocate)
		$(use_enable unshare)
		$(use_enable nsenter)
		$(use_enable setpriv)
		$(use_enable eject)
		$(use_enable agetty)
		$(use_enable plymouth-support plymouth_support)
		$(use_enable cramfs)
		$(use_enable bfs)
		$(use_enable minix)
		$(use_enable fdformat)
		$(use_enable hwclock)
		$(use_enable lslogins)
		$(use_enable wdctl)
		$(use_enable cal)
		$(use_enable logger)
		$(use_enable switch_root)
		$(use_enable pivot_root)
		$(use_enable ipcrm)
		$(use_enable ipcs)
		$(use_enable tunelp)
		$(use_enable kill)
		$(use_enable last)
		$(use_enable utmpdump)
		$(use_enable line)
		$(use_enable mesg)
		$(use_enable raw)
		$(use_enable rename)
		$(use_enable reset)
		$(use_enable vipw)
		$(use_enable newgrp)

		$(use_enable chfn-chsh-password)
		$(use_enable chfn-chsh)
		$(use_enable chsh-only-listed)
		$(use_enable login)
		$(use_enable login-chown-vcs)
		$(use_enable login-stat-mail)
		$(use_enable nologin)
		$(use_enable sulogin)
		$(use_enable su)
		$(use_enable runuser)
		$(use_enable ul)
		$(use_enable more)
		$(use_enable pg)
		$(use_enable setterm)
		$(use_enable schedutils)
		$(use_enable wall)
		$(use_enable write)
		$(use_enable pylibmount)
		$(use_enable pg-bell)
# 		$(use_enable fs-paths-default)	# default search path for fs helpers [/sbin:/sbin/fs.d:/sbin/fs]
# 		$(use_enable fs-paths-extra)	# additional search paths for fs helpers
		$(use_enable use-tty-group)
		$(use_enable sulogin-emergency-mount)
		$(use_enable usrdir-path)
		$(use_enable suid makeinstall-chown)	# do not do chown-like operations during "make install"
		$(use_enable suid makeinstall-setuid)	# do not do setuid chmod operations during "make install"
		$(use_enable colors-default)

		$(use_with util)
		$(use_with selinux)
		$(use_with audit)
		$(use_with udev)

		# build with non-wide ncurses, default is wide version (--without-ncurses disables all ncurses(w) support)
		--with-ncurses="$(usex ncurses $(usex unicode auto yes) no)"
		$(use_with slang)
		$(use_with tinfo)	# compile without libtinfo
		$(use_with readline)

		$(use_with utempter)
		$(use_with cap-ng)
		$(use_with libz)
		$(use_with user)
		$(use_with btrfs)
		$(use_with systemd)
		$(use_with smack)
		$(use_with libpython python)	# do not build python bindings, use --with-python={2,3} to force version

		# link static the programs in LIST (comma-separated,
		#                  supported for losetup, mount, umount, fdisk, sfdisk, blkid, nsenter, unshare)
# 		--enable-static-programs=
	)

	econf "${my_econf_args[@]}"
}

src_install() {
	default

	dodoc AUTHORS NEWS README* Documentation/{TODO,*.txt,releases/*}

	# e2fsprogs-libs didnt install .la files, and .pc work fine
	prune_libtool_files

	# need the libs in /
	local gul_args=(
		$(usex libblkid blkid '')
		$(usex mount mount '')
		$(usex libsmartcols smartcols '')
		$(usex libuuid uuid '')
	)
	(( ${#gul_args[@]} )) && gen_usr_ldscript -a "${gul_args[@]}"

	use libpython && python_optimize
}
