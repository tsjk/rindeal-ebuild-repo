# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# git-hosting.eclass
GH_URI="github"
GH_REF="v${PV}"
# python-.eclass
PYTHON_COMPAT=( python{2_7,3_3,3_4,3_5} )

inherit rindeal
# eautoreconf()
inherit autotools
# getpam_mod_dir()
inherit pam
# tc-*()
inherit toolchain-funcs
# enewuser()/enewgroup()
inherit user
# get_bashcompdir()
inherit bash-completion-r1
# systemd_update_catalog()
inherit systemd
# udev_reload()
inherit udev
# EXPORT_FUNCTIONS: pkg_setup
inherit linux-info
# EXPORT_FUNCTIONS: pkg_setup
inherit python-any-r1
# EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

DESCRIPTION="System and service manager for Linux"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/systemd"
# licences are described in 'README' file
LICENSE_A=(
	'LGPL-2.1+' # most of the code
	'GPL-2' # udev
	'public-domain' # MurmurHash2, siphash24, lookup3
)

# - the subslot versioning follows Gentoo
# - incremented for ABI breaks in libudev or libsystemd
SLOT="0/2"

KEYWORDS=""
IUSE_A=(
	## generic
	+man nls test vanilla python

	## daemons
	+hostnamed importd +localed +logind machined networkd resolved +timedated timesyncd

	## utils
	backlight coredump +firstboot quotacheck randomseed rfkill +sysusers +tmpfiles

	## security modules
	apparmor audit ima seccomp selinux smack
	## security modules2
	acl +pam policykit tpm

	## compression
	bzip2 lz4 lzma zlib

	## EFI
	efi gnuefi

	## gimmick
	-qrcode -http -ssl

	## misc
	binfmt +blkid cryptsetup curl +elfutils gcrypt hibernate +hwdb idn +kmod libiptc myhostname
	+utmp +vconsole xkb

	nat sysv-utils
)

# deps are specified in 'README' file
CDEPEND_A=(
	">=sys-libs/glibc-2.16"
	"sys-libs/libcap:0="
	# >v2.27.1 since 228
	# "*must* be built with --enable-libmount-force-mountinfo"
	# TODO: how to enforce the above condition?
	">=sys-apps/util-linux-2.27.1:0="

	"acl? ( sys-apps/acl:0= )"
	"apparmor? ( sys-libs/libapparmor:0= )"
	"audit? ( >=sys-process/audit-2:0= )"
	"cryptsetup? ( sys-fs/cryptsetup:0= )"
	"curl? ( net-misc/curl:0= )"
	"elfutils? ( >=dev-libs/elfutils-158:0= )"
	"gcrypt? ("
		"dev-libs/libgcrypt:0="
		"dev-libs/libgpg-error"
	")"
	"http? ("
		"net-libs/libmicrohttpd:0="
		"ssl? ( net-libs/gnutls:0= ) )"
	"idn? ( net-dns/libidn:0= )"
	"kmod? ( >=sys-apps/kmod-15:0= )"

	## compression
	"bzip2?	( app-arch/bzip2:0= )"
	"lz4?	( >=app-arch/lz4-0_p131:0= )"
	"lzma?	( app-arch/xz-utils:0= )"
	"zlib?	( sys-libs/zlib:0= )"

	"nat? ( net-firewall/iptables:0= )"
	"pam? ( virtual/pam:= )"
	"qrcode? ( media-gfx/qrencode:0= )"
	"seccomp? ( >=sys-libs/libseccomp-1.0.0:0= )"
	"selinux? ( sys-libs/libselinux:0= )"
	"sysv-utils? ("
		"!sys-apps/systemd-sysv-utils"
		"!sys-apps/sysvinit )"
	"xkb? ( x11-libs/libxkbcommon:0= )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	# for keymap; TODO: find out more
	"dev-util/gperf"
	# systemd depends heavily on a recent version of binutils
	">=sys-devel/binutils-2.23.1"
	"sys-kernel/linux-headers"
	"sys-devel/gettext" # localed, core-dbus
	"virtual/pkgconfig"

	"gnuefi? ( >=sys-boot/gnu-efi-3.0.2 )"
	"man? ("
		# for creating the man pages (used in {less-variables,standard-options}.xml)
		"app-text/docbook-xml-dtd:4.5"
		# xsltproc - for creating the man pages
		"dev-libs/libxslt:0"
		"app-text/docbook-xsl-stylesheets"

		"python? ("
			# lxml is for generating the man page index
			"$(python_gen_any_dep 'dev-python/lxml[${PYTHON_USEDEP}]')"
		")"
	")"
	"nls? ( dev-util/intltool )"
	"python? ( ${PYTHON_DEPS} )"
	# tests use dbus
	"test? ( sys-apps/dbus:0 )"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"selinux? ( sec-policy/selinux-base-policy[systemd] )"
	"myhostname? ( !sys-auth/nss-myhostname )" # bundled since 197
	"!<sys-kernel/dracut-044"
	## udev is now part of systemd
	"!sys-fs/eudev"
	"!sys-fs/udev"
)
PDEPEND_A=(
	# the daemon only (+ build-time lib dep for tests)
	">=sys-apps/dbus-1.4.0:0[systemd]"
	# Gentoo specific suplement of bundled hwdb.d rules + some more
	"hwdb? ( sys-apps/hwids[udev] )"
	# ">=sys-fs/udev-init-scripts-25" # required for systemd+OpenRC support only
	"policykit? ( sys-auth/polkit[systemd] )"
	"!vanilla? ( sys-apps/gentoo-systemd-integration )"
)

REQUIRED_USE_A=(
	# specified in Makefile.am
	"efi? ( blkid )"
	"gnuefi? ( efi )"
	"importd? ( curl lzma zlib bzip2 gcrypt )"
)

inherit arrays

my_get_rootprefix() {
	echo "${ROOTPREFIX-"/usr"}"
}

python_check_deps() {
	# choose the first python that has lxml
	has_version --host-root "dev-python/lxml[${PYTHON_USEDEP}]"
}

pkg_pretend() {
	# TODO: ewarn of bugs that are in this release

	[[ -n "${EPREFIX}" ]] && \
		die "Gentoo Prefix is not supported"

	# config options are specified in 'README'
	local CONFIG_CHECK_A=(
		##  file as required
		'~DEVTMPFS'
		'~CGROUPS'
		'~INOTIFY_USER'
		'~SIGNALFD'
		'~TIMERFD'
		'~EPOLL'
		'~NET'
		'~SYSFS'
		'~PROC_FS'
		'~FHANDLE'
		# udev
		'~!SYSFS_DEPRECATED'
		'~!SYSFS_DEPRECATED_V2'
		# Userspace firmware loading is not supported
		'~!FW_LOADER_USER_HELPER'

		# Required for PrivateNetwork and PrivateDevices
		'~NET_NS'
		$(kernel_is -lt 4 7 &>/dev/null && echo '~DEVPTS_MULTIPLE_INSTANCES')

		# Required for CPUShares= in resource control unit settings
		'~CGROUP_SCHED'
		'~FAIR_GROUP_SCHED'

		## optional
		# HW support
		'~DMIID'
		'~BLK_DEV_BSG'
		# ipv6
		'~IPV6'
		#if deselected, systemd issues warning on each boot, but otherwise works the same
		'~AUTOFS4_FS'
		# acl
		'~TMPFS_XATTR'
		$(use acl && echo '~TMPFS_POSIX_ACL')
		# seccomp
		$(use seccomp && echo '~SECCOMP')
		# for the kcmp() syscall
		'~CHECKPOINT_RESTORE'
		# Required for CPUQuota= in resource control unit settings
		'~CFS_BANDWIDTH'
		# efi
		$(use efi && echo '~EFIVAR_FS ~EFI_PARTITION')
		# real-time group scheduling - see 'README'
		'~!RT_GROUP_SCHED'
		# systemd doesn't like it - see 'README'
		'~!AUDIT'

		'~!GRKERNSEC_PROC'
		'~!IDE'
	)

	CONFIG_CHECK="${CONFIG_CHECK_A[@]}"

	CONFIG_CHECK="${CONFIG_CHECK_A[@]}"

	if linux_config_exists ; then
		local uevent_helper_path=$(linux_chkconfig_string UEVENT_HELPER_PATH)
		if [[ -n "${uevent_helper_path}" ]] && [[ "${uevent_helper_path}" != '""' ]]; then
			ewarn "Legacy hotplug slows down the system and confuses udev."
			ewarn "It's recommended to set an empty value to the following kernel config option:"
			ewarn "CONFIG_UEVENT_HELPER_PATH=\"${uevent_helper_path}\""
		fi
	fi

	if [[ ${MERGE_TYPE} != buildonly ]]; then
		check_extra_config
	fi
}

pkg_setup() {
	linux-info_pkg_setup
	python-any-r1_pkg_setup
}

src_prepare() {
	eapply "${FILESDIR}/218-Dont-enable-audit-by-default.patch"
	eapply "${FILESDIR}/228-noclean-tmp.patch"
	eapply "${FILESDIR}/231-bootctl_fix_error_message_check.patch"
	eapply "${FILESDIR}/231-bootctl_minor_coding_style_improvements.patch"
	eapply "${FILESDIR}/231-bootctl_rework_to_use_common_verbs_parsing_and_add_search.patch"
	eapply "${FILESDIR}/231-build_sys_get_rid_of_move_to_rootlibdir.patch"
	eapply "${FILESDIR}/231-core_do_not_fail_at_step_SECCOMP_if_there_is_no_kernel_su.patch"
	eapply "${FILESDIR}/231-fix_test-path-util_lt_prefix.patch"
	eapply "${FILESDIR}/231-manager-ignore_0_length_notification_messages.patch"
	eapply "${FILESDIR}/231-networkd_limit_the_number_of_routes_to_the_kernel_limit_4.patch"
	eapply "${FILESDIR}/231-networkd_test_add_a_helper_function_to_always_clean_up_test.patch"
	eapply "${FILESDIR}/231-nss_install_nss_modules_to_rootlibdir.patch"
	eapply "${FILESDIR}/231-pid1_dont_return_any_error_in_manager_dispatch_notify_fd.patch"
	eapply "${FILESDIR}/231-pid1_process_zero_length_notification_messages_again.patch"
	eapply "${FILESDIR}/231-resolved_dont_query_domain_limited_DNS_servers_for_other.patch"
	eapply "${FILESDIR}/231-Revert_logind_really_handle_KeyIgnoreInhibited_options_in_logind_conf.patch"
	eapply "${FILESDIR}/231-Revert_pid1_reconnect_to_the_console_before_being_re_exec.patch"
	eapply "${FILESDIR}/231-seccomp_also_detect_if_seccomp_filtering_is_enabled.patch"
	eapply "${FILESDIR}/231-shared_recognize_DNS_names_with_more_than_one_trailing_do.patch"
	eapply "${FILESDIR}/231-systemctl_consider_service_running_only_when_it_is_in_act.patch"
	eapply_user

	# 'uucp' group is prefered for this purpose in Gentoo (gentoo#463376)
	sed -e 's,GROUP="dialout",GROUP="uucp",' \
		-i -- rules/*.rules || die
	# default to https (support/bug report/etc. urls)
	sed -e 's,http://,https://,g' \
		-i -- configure.ac || die
	# use an eclass when we have it, the result is the same, but hey, it's an eclass
	sed -e "s,\(udevlibexecdir=\),\1$(get_udevdir)," \
		-i -- Makefile.am || die
	# Avoid the log bloat to the user
	sed -e 's,#SystemMaxUse=,SystemMaxUse=500M,' \
		-i -- src/journal/journald.conf || die
	# work around a bug in libsandbox (gentoo#590084)
	sed -e '\|test_get_files_in_directory();|d' \
		-e '\|test_readlink_and_make_absolute();|i test_get_files_in_directory();' \
		-i -- src/test/test-fs-util.c || die
	# Bug https://github.com/systemd/systemd/issues/3826
	sed -e 's,/usr/lib/systemd/resolv.conf,/run/systemd/resolve/resolv.conf,' \
		-i -- tmpfiles.d/etc.conf.m4 || die
	# efi_cflags
	sed -e '/-ggdb -O0 \\/d' -i -- Makefile.am || die

	eautoreconf
}

src_configure() {
	# work around bug in gobject-introspection (gentoo#463846)
	tc-export CC

	local econf_args=(
		# TODO: replace with '--disable-lto' in v232
		cc_cv_CFLAGS__flto=no
		# Disable -fuse-ld=gold since Gentoo supports explicit linker
		# choice and forcing gold is undesired. (gentoo#539998)
		# ld.gold may collide with user's LDFLAGS. (gentoo#545168)
		cc_cv_LDFLAGS__Wl__fuse_ld_gold=no

		# TODO: we may need to restrict this to gcc
		EFI_CC="$(tc-getCC)"

		--disable-static
		# workaround for bug 516346
# 		--enable-dependency-tracking
		# controverse autoconf feature
		--disable-maintainer-mode

		### Paths
		## hardcode a few paths to prevent autoconf from looking for them and
		## thus sparing some deps
		KILL="/bin/kill"
		QUOTAON="/usr/sbin/quotaon"
		QUOTACHECK="/usr/sbin/quotacheck"
		--with-kbd-loadkeys="/usr/bin/loadkeys"
		--with-kbd-setfont="/usr/bin/setfont"
		--with-telinit="/sbin/telinit"

		--localstatedir=/var
		## avoid bash-completion dep (configure.ac would call pkg-config)
		--with-bashcompletiondir="$(get_bashcompdir)"
		# FIXME: ZSH completion dir
		# --with-zshcompletiondir # defaults to ${datadir}/zsh/site-functions
		## dbus paths
		--with-dbuspolicydir="/etc/dbus-1/system.d"
		--with-dbussessionservicedir="/usr/share/dbus-1/services"
		--with-dbussystemservicedir="/usr/share/dbus-1/system-services"
		# TODO: ??
		--with-pamlibdir="$(getpam_mod_dir)"
		## For testing.
		--with-rootprefix="$(my_get_rootprefix)"
		--with-rootlibdir="$(my_get_rootprefix)/$(get_libdir)"
		## disable sysv compatibility
		--with-sysvinit-path=
		--with-sysvrcnd-path=

		# make sure we get /bin:/sbin in $PATH
		# "Assume that /bin, /sbin aren't symlinks into /usr"
		--enable-split-usr
		# just install ldconfig.service
		--enable-ldconfig
		## enable administrative ACL settings for these groups
		--enable-adm-group
		--enable-wheel-group

		# do not kill user process on logout, it breaks screen/tmux sessions, etc.
		--without-kill-user-processes

		## generic options
		$(use_enable nls)
		$(use_enable test tests)	# disable tests, or enable extra tests with =unsafe
		$(use_enable test dbus)		# disable usage of dbus-1 in tests
		$(use_enable man manpages)
		#--enable-debug[=LIST]   enable extra debugging (hashmap,mmap-cache)
		$(use_with python)

		## systemd daemons
		$(use_enable hostnamed)	# systemd-hostnamed(8)
		$(use_enable importd)	# systemd-importd(8)
		$(use_enable localed)	# systemd-localed(8)
		$(use_enable logind)	# systemd-logind(8)
		$(use_enable machined)	# systemd-machined(8)
		$(use_enable networkd)	# systemd-networkd(8)
		$(use_enable resolved)	# systemd-resolved(8)
		$(use_enable timedated)	# systemd-timedated(8)
		$(use_enable timesyncd)	# systemd-timesyncd(8)

		## systemd utils
		$(use_enable backlight)	# systemd-backlight(8)
		$(use_enable coredump)	# systemd-coredump(8)
		$(use_enable firstboot)	# systemd-firstboot(1)
		$(use_enable quotacheck)	# systemd-quotacheck(8)
		$(use_enable randomseed)	# systemd-randomseed(8)
		$(use_enable rfkill)	# systemd-rfkill(8)
		$(use_enable sysusers)	# sysusers.d(5)
		$(use_enable tmpfiles)	# tmpfiles.d(5)

		## optional security modules
		$(use_enable apparmor)
		$(use_enable audit)
		$(use_enable ima)
		$(use_enable seccomp)
		$(use_enable selinux)
		$(use_enable smack)

		## security modules 2
		$(use_enable acl)
		$(use_enable pam)
		$(use_enable policykit polkit)
		$(use_enable tpm)

		## compression algorithms
		$(use_enable bzip2)
		$(use_enable lz4)
		$(use_enable lzma xz)
		$(use_enable zlib)

		## EFI
		$(use_enable efi)
		$(use_enable gnuefi)

		## gimmick
		$(use_enable http microhttpd)
		# if use_http && use_ssl then --enable-gnutls else --disable-gnutls
		$(use_enable $(usex http ssl http) gnutls)
		$(use_enable qrcode qrencode)

		## misc
		$(use_enable binfmt)	# emulators (Wine, qemu, ...)
		$(use_enable blkid)
		$(use_enable cryptsetup libcryptsetup)
		$(use_enable curl libcurl)
		$(use_enable elfutils)
		$(use_enable gcrypt)
		$(use_enable hibernate)
		$(use_enable hwdb)
		$(use_enable idn libidn)
		$(use_enable kmod)
		$(use_enable libiptc)
		$(use_enable myhostname)
		$(use_enable utmp)
		$(use_enable vconsole)
		# - NEWS: "systemd-localed will verify x11 keymap settings by compiling the given keymap"
		# - enable for desktops
		$(use_enable xkb xkbcommon)
	)

	: "${SYSTEMD_WITH_NTP_SERVERS:="$( echo {0..3}'.gentoo.pool.ntp.org' )"}"
	# Google DNS servers, another alternative is https://www.opennicproject.org/ or leave empty
	: "${SYSTEMD_WITH_DNS_SERVERS:="$( echo 8.8.{8.8,4.4} 2001:4860:4860::88{88,44} )"}"

	# used for options which can be modified based on env vars
	my_with() {
		local use_flag="${1}" option_name="${2}"
		local var="SYSTEMD_WITH_${use_flag^^}"
		local with="${option_name:-"${use_flag,,}"}"
		var="${var//-/_}" ; with="${with//_/-}"

		[[ -v "${var}" ]] && \
			printf "%s-%s=%s\n" "--with" "${with}" "${!var}"

		return 0
	}

	econf_args+=(
		"$(my_with debug-shell)"	# Path to debug shell binary
		"$(my_with debug-tty)"		# Specify the tty device for debug shell
		"$(my_with certificate-root)"	# Specify the prefix for TLS certificates [/etc/ssl]

		"$(my_with support-url)"	# Specify the supoport URL to show in catalog entries included in systemd

		"$(my_with smack-run-label)"	# run systemd --system itself with a specific SMACK label
		"$(my_with smack-default-process-label)"	# default SMACK label for executed processes

		"$(my_with ntp-servers)"	# systemd-timesyncd default servers
		"$(my_with time-epoch)"	# minimal clock value specified as UNIX timestamp

		"$(my_with tpm-pcrindex)"	# TPM PCR register number to use

		"$(my_with system-uid-max)"
		"$(my_with system-gid-max)"

		"$(my_with dns-servers)"	# systemd-resolved default servers
		"$(my_with default-dnssec)"	# Default DNSSEC mode, accepts boolean, defaults to "allow-downgrade"

		"$(my_with tty-gid)"

		## TODO: coming in v232
# 		"$(my_with nobody-user)"	# Specify the name of the nobody user (the one with UID 65534)
# 		"$(my_with nobody-group)"	# Specify the name of the nobody group (the one with GID 65534)
	)

	econf "${econf_args[@]}"
}

src_install() {
	local mymakeopts=(
		# do not install hwdb.d rules
		# Gentoo packages it separately as sys-apps/hwids
		dist_udevhwdb_DATA=

		DESTDIR="${D}"

		# automake fails with parallel libtool relinking (gentoo#491398)
		-j1
	)

	emake "${mymakeopts[@]}" install
	prune_libtool_files --modules

	einstalldocs

	# python script generates the index
	use python && \
		doman "${WORKDIR}"/man/systemd.{directives,index}.7

	if use sysv-utils ; then
		local app
		for app in halt poweroff reboot runlevel shutdown telinit ; do
			dosym "..$(my_get_rootprefix)/bin/systemctl" "/sbin/${app}"
		done
		dosym "..$(my_get_rootprefix)/lib/systemd/systemd" '/sbin/init'
	elif use man ; then
		## we just keep sysvinit tools, so no need for the mans
		erm "${ED}"/usr/share/man/man8/{halt,poweroff,reboot,runlevel,shutdown,telinit}.8
		erm "${ED}"/usr/share/man/man1/init.1
	fi

	# Preserve empty dirs in /etc & /var, (gentoo#437008)
	keepdir /etc/binfmt.d \
		/etc/kernel/install.d \
		/etc/modules-load.d \
		/etc/systemd/network \
		/etc/systemd/ntp-units.d \
		/etc/systemd/user \
		/etc/tmpfiles.d \
		/etc/udev/hwdb.d \
		/etc/udev/rules.d \
		/usr/lib/modules-load.d \
		/usr/lib/systemd/{user-generators,system-{sleep,shutdown}} \
		/var/lib/systemd \
		/var/log/journal/remote

	# Symlink /etc/sysctl.conf for easy migration.
	dosym "../sysctl.conf" "/etc/sysctl.d/99-sysctl.conf"

	## If we install these symlinks, there is no way for the sysadmin to remove
	## them permanently.
	epushd "${ED}"/etc/systemd/system # {
	use sysv-utils && erm -r sysinit.target.wants
	use networkd && erm -r \
		multi-user.target.wants/systemd-networkd.service \
		{network-online,sockets}.target.wants
	use resolved && erm -r multi-user.target.wants/systemd-resolved.service
	epopd # }
}

# set to 1 if some pkg_postinst phase fails
FAIL=0

my_migrate_locale_settings() {
	local envd_locale_def="${ROOT%/}/etc/env.d/02locale"
	local envd_locale=( "${ROOT%/}"/etc/env.d/??locale )
	local locale_conf="${ROOT%/}/etc/locale.conf"

	# If locale.conf does not exist...
	if [[ ! -L ${locale_conf} && ! -e ${locale_conf} ]] ; then
		# ...either copy env.d/??locale if there's one
		if [[ -e ${envd_locale} ]] ; then
			ebegin "Moving ${envd_locale} to ${locale_conf}"
			mv "${envd_locale}" "${locale_conf}"
			eend $? || FAIL=1

		# ...or create a dummy default
		else
			ebegin "Creating ${locale_conf}"
			cat > "${locale_conf}" <<-EOF
				# This file has been created by the ${CATEGORY}/${PF} ebuild.
				# See locale.conf(5) and localectl(1).

				# LANG=${LANG}
			EOF
			eend $? || FAIL=1
		fi
	fi

	# now, if env.d/??locale is not a symlink (to locale.conf)...
	if [[ ! -L ${envd_locale} ]] ; then
		# ... check if the user has duplicate locale settings
		if [[ -e ${envd_locale} ]] ; then
			ewarn
			ewarn "To ensure consistent behavior, you should replace ${envd_locale}"
			ewarn "with a symlink to ${locale_conf}. Please migrate your settings"
			ewarn "and create the symlink with the following command:"
			ewarn "    ln -s -n -f ../locale.conf ${envd_locale}"
			ewarn

		# ...or just create the symlink if there's nothing here
		else
			ebegin "Creating ${envd_locale_def} -> ../locale.conf symlink"
			ln --no-dereference -s '../locale.conf' "${envd_locale_def}"
			eend $? || FAIL=1
		fi
	fi
}

pkg_postinst() {
	my_newusergroup() {
		enewgroup "$1"
		enewuser "$1" -1 -1 -1 "$1"
	}

	## NOTE: do not make the creation of users/groups conditional
	enewgroup input
	enewgroup systemd-journal
	my_newusergroup systemd-bus-proxy
	my_newusergroup systemd-coredump
	my_newusergroup systemd-journal-gateway
	my_newusergroup systemd-journal-remote
	my_newusergroup systemd-journal-upload
	my_newusergroup systemd-network
	my_newusergroup systemd-resolve
	my_newusergroup systemd-timesync

	systemd_update_catalog

	# Keep this here in case the database format changes so it gets updated
	# when required. Despite that this file is owned by sys-apps/hwids.
	if has_version "sys-apps/hwids[udev]" ; then
		einfo "Updating hwdb database"
		nonfatal udevadm hwdb --update --root="${ROOT%/}"
	fi

	udev_reload || FAIL=1

	# Make sure locales are respected, and ensure consistency between OpenRC & systemd.
	# Bug gentoo#465468.
	my_migrate_locale_settings

	if (( ${FAIL} )) ; then
		eerror "One of the post-installation commands failed. Please check the postinst output"
		eerror "for errors. You may need to clean up your system and/or try installing"
		eerror "${PN} again."
		eerror
	fi

	#if use resolved && [[ $(readlink "${ROOT}"etc/resolv.conf) == */run/systemd/* ]]; then
	#	ewarn "You should replace the resolv.conf symlink:"
	#	ewarn "ln -snf $(my_get_rootprefix)/lib/systemd/resolv.conf ${ROOT}etc/resolv.conf"
	#fi

	if ! [[ "$(readlink "${ROOT}/etc/mtab")" == *"/proc/self/mounts" ]] ; then
		ewarn "'${ROOT}/etc/mtab' is not a symlink to '/proc/self/mounts'!"
	fi
}

pkg_prerm() {
	# If removing systemd completely, remove the catalog database.
	if [[ -z "${REPLACED_BY_VERSION}" ]] ; then
		nonfatal erm "${ROOT}/var/lib/systemd/catalog/database"
	fi
}
