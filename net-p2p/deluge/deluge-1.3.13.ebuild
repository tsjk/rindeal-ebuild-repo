# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI='6'

PYTHON_COMPAT=( python2_7 )
DISTUTILS_SINGLE_IMPL=true

inherit distutils-r1 eutils systemd

DESCRIPTION='BitTorrent client with a client/server model'
HOMEPAGE='http://deluge-torrent.org/'
LICENSE='GPL-2'

SLOT='0'
SRC_URI="http://git.deluge-torrent.org/deluge/snapshot/${P}.tar.bz2"

KEYWORDS='~amd64 ~arm'
IUSE='console +daemon geoip +gtk +libnotify +setproctitle +sound webui'

CDEPEND_A=(
	"daemon? ("
		# deluge devs said that there is no support for libtorrent-1.1.x in deluge-1.3.x
		"net-libs/libtorrent-rasterbar:0/8[python,${PYTHON_USEDEP}]"
	")"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
	"dev-util/intltool" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/chardet[${PYTHON_USEDEP}]"
	"dev-python/pyopenssl[${PYTHON_USEDEP}]"
	"dev-python/pyxdg[${PYTHON_USEDEP}]"
	">=dev-python/twisted-core-8.1[${PYTHON_USEDEP}]"
	">=dev-python/twisted-web-8.1[${PYTHON_USEDEP}]"

	"geoip? ( dev-libs/geoip )"
	"gtk? ("
		"libnotify? ( dev-python/notify-python[${PYTHON_USEDEP}] )"
		"sound? ( dev-python/pygame[${PYTHON_USEDEP}] )"
		"dev-python/pygobject:2[${PYTHON_USEDEP}]"
		">=dev-python/pygtk-2.12:2[${PYTHON_USEDEP}]"
		"gnome-base/librsvg"
	")"
	"setproctitle? ( dev-python/setproctitle[${PYTHON_USEDEP}] )"
	"webui? ( dev-python/mako[${PYTHON_USEDEP}] )"
)

REQUIRED_USE="
	sound? ( gtk )
	libnotify? ( gtk )
	|| ( console daemon gtk webui )"

inherit arrays

L10N_LOCALES=( af ar ast be bg bn bs ca cs cy da de el en_AU en_CA en_GB eo es et eu fa fi fo fr fy ga gl
	he hi hr hu id is it ja ka kk km kn ko ku ky la lb lt lv mk ml ms nb nds nl nn oc pl pt pt_BR ro
	ru si sk sl sr sv ta te th tl tlh tr uk ur vi zh_CN zh_HK zh_TW )
L10N_LOCALES_MASK=( nap pms iu )
inherit l10n-r1

src_prepare-locales() {
	local l locales dir='deluge/i18n' pre='' post='.po'

	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"

	l10n_get_locales locales app off
	for l in ${locales} ; do
		rm -v -f "${dir}/${pre}${l}${post}" || die
	done
}

python_prepare_all() {
	# disable libtorrent checks
	sed -e 's|build_libtorrent = True|build_libtorrent = False|' \
		-e "/Compiling po file/a \\\tuptoDate = False" \
        -i -- 'setup.py' || die
	# disable new release checks
	sed -e 's|"new_release_check": True|"new_release_check": False|' \
        -i -- 'deluge/core/preferencesmanager.py' || die

	src_prepare-locales

	distutils-r1_python_prepare_all
}

esetup.py() {
	# bug 531370: deluge has its own plugin system. No need to relocate its egg info files.
	# Override this call from the distutils-r1 eclass.
	# This does not respect the distutils-r1 API. DO NOT copy this example.
	set -- "${PYTHON}" setup.py "$@"
	echo "$@"
	"$@" || die
}

python_install_all() {
	distutils-r1_python_install_all

	local rm_paths=()

	if use daemon ; then
		# TODO: drop OpenRC support on deluge-1.4 release
		newinitd "${FILESDIR}/deluged.init" 'deluged'
		newconfd "${FILESDIR}/deluged.conf" 'deluged'

		systemd_dounit "${FILESDIR}/deluged@.service"
	else
		rm_paths+=(
			"${ED}/usr/bin/deluged"
			"${ED}/usr/share/man/man1"/deluged.* )
	fi

	if use webui ; then
		# TODO: drop OpenRC support on deluge-1.4 release
		newinitd "${FILESDIR}/deluge-web.init" 'deluge-web'
		newconfd "${FILESDIR}/deluge-web.conf" 'deluge-web'
	else
		rm_paths+=(
			"${ED}/usr/bin/deluge-web"
			"${ED}/usr"/lib*/py*/*-packages/deluge/ui/web/
			"${ED}/usr/share/man/man1"/deluge-web.* )
	fi

	if ! use gtk ; then
		rm_paths+=(
			"${ED}/usr/bin/deluge-gtk"
			"${ED}/usr"/lib*/py*/*-packages/deluge/ui/gtkui/
			"${ED}/usr/share/applications/"
			"${ED}/usr/share/icons/"
			"${ED}/usr/share/man/man1"/deluge-gtk.* )
	fi

	if ! use console ; then
		rm_paths+=(
			"${ED}/usr/bin/deluge-console"
			"${ED}/usr"/lib*/py*/*-packages/deluge/ui/console/*
			"${ED}/usr/share/man/man1"/deluge-console.* )
	fi

	if ! use gtk && ! use webui ; then
		rm_paths+=(
			"${ED}/usr/share/pixmaps/"
			"${ED}/usr"/lib*/py*/*-packages/deluge/data/pixmaps/ )
	fi

	rm -rvf "${rm_paths[@]}" || die
}
