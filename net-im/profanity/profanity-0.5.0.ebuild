# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# git-hosting.eclass
GH_URI="github/boothj5"
# python-*.eclass
PYTHON_COMPAT=( python2_7 )

inherit git-hosting
# functions: eautoreconf
inherit autotools
# EXPORT_FUNCTIONS: pkg_setup
inherit python-single-r1
# functions: prune_libtool_files, newicon
inherit eutils

DESCRIPTION="Ncurses based XMPP client inspired by Irssi"
HOMEPAGE="http://profanity.im/ ${GH_HOMEPAGE}"
LICENSE="GPL-3+"

SLOT="0"

KEYWORDS="~amd64 ~arm"
IUSE_A=( pgp icons +notifications otr +plugins +themes xscreensaver python-plugins +c-plugins test +largefile )

CDEPEND_A=(
	# python-config
	"python-plugins? ( ${PYTHON_DEPS} )"
	# -ldl
	# c-plugins? (  )
	"|| ("
		# pkg-config: libmesode
		">=dev-libs/libmesode-0.9.0"
		# pkg-config: libstrophe
		">=dev-libs/libstrophe-0.9.0"
	")"
	# pkg-config: ncursesw
	"sys-libs/ncurses:0[unicode]"
	# pkg-config: 'glib-2.0 >= 2.26'
	">=dev-libs/glib-2.26:2"
	# pkg-config: libcurl
	"net-misc/curl"
	"icons? ("
		# pkg-config: gtk+-2.0 >= 2.24.10
		">=x11-libs/gtk+-2.24.10:2"
	")"
	# libreadline
	"sys-libs/readline:0"
	"notifications? ("
		# pkg-config: libnotify
		"x11-libs/libnotify"
	")"
	"xscreensaver? ("
		# libXss
		"x11-libs/libXScrnSaver"
		# libX11
		"x11-libs/libX11"
	")"
	# "!xscreensaver? ( same as 'xscreensaver', but doesn't fail if not found )"
	"pgp? ("
		# libgpgme + gpgme-config
		"app-crypt/gpgme"
	")"
	"otr? ("
		# libotr
		"net-libs/libotr"
	")"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"sys-devel/libtool"
	"virtual/pkgconfig"
	"test? ("
		"dev-util/cmocka"
# 		"net-im/stabber" # weak dep
# 		"dev-tcltk/expect" # weak dep
	")"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

REQUIRED_USE_A=(
	"python-plugins? ( ${PYTHON_REQUIRED_USE} )"
)
RESTRICT+=""

src_prepare() {
	default

	eautoreconf
}

src_configure() {
	local myeconfargs=(
		$(use_enable pgp)
		$(use_enable largefile)
		$(use_enable icons)
		$(use_enable notifications)
		$(use_enable otr)
		$(use_with themes)
		$(use_with xscreensaver)

		$(use_enable plugins) # can disable all other plugins
		$(use_enable c-plugins)
		$(use_enable python-plugins)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	newicon "${FILESDIR}/${PN}_logo.png" "${PN}.png"

	local make_desktop_entry_args=(
		"${EPREFIX}/usr/bin/${PN}"    # exec
		"${PN^}"    # name
		"${PN}"     # icon
		'Network;InstantMessaging;Chat' # categories
	)
	local make_desktop_entry_extras=(
		'Terminal=true'
	)
	make_desktop_entry "${make_desktop_entry_args[@]}" \
		"$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"

	prune_libtool_files
}
