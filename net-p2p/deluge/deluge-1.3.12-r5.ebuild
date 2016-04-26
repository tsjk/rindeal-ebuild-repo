# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI='6'

PYTHON_COMPAT=( python2_7 )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 eutils user

DESCRIPTION='BitTorrent client with a client/server model'
HOMEPAGE='http://deluge-torrent.org/'
LICENSE='GPL-2'
SRC_URI="http://download.deluge-torrent.org/source/${P}.tar.bz2"

KEYWORDS='~amd64 ~arm ~x86'
SLOT='0'

IUSE='console +daemon geoip +gtk +libnotify +setproctitle +sound webui'
REQUIRED_USE='
	sound? ( gtk )
	libnotify? ( gtk )
	|| ( console daemon gtk webui )'

CDEPEND="daemon? ( >=net-libs/libtorrent-rasterbar-0.14.9:0[python,${PYTHON_USEDEP}] )"
DEPEND="${CDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-util/intltool"
RDEPEND="${CDEPEND}
	dev-python/chardet[${PYTHON_USEDEP}]
	dev-python/pyopenssl[${PYTHON_USEDEP}]
	dev-python/pyxdg[${PYTHON_USEDEP}]
	>=dev-python/twisted-core-8.1[${PYTHON_USEDEP}]
	>=dev-python/twisted-web-8.1[${PYTHON_USEDEP}]

	geoip? ( dev-libs/geoip )
	gtk? (
		libnotify? ( dev-python/notify-python[${PYTHON_USEDEP}] )
		sound? ( dev-python/pygame[${PYTHON_USEDEP}] )
		dev-python/pygobject:2[${PYTHON_USEDEP}]
		>=dev-python/pygtk-2.12:2[${PYTHON_USEDEP}]
		gnome-base/librsvg
	)
	setproctitle? ( dev-python/setproctitle[${PYTHON_USEDEP}] )
	webui? ( dev-python/mako[${PYTHON_USEDEP}] )"

PLOCALES='af ar ast be bg bn bs ca cs cy da de el en_AU en_CA en_GB eo es et eu fa fi fo fr fy ga gl
	he hi hr hu id is it ja ka kk km kn ko ku ky la lb lt lv mk ml ms nb nds nl nn oc pl pt pt_BR ro
	ru si sk sl sr sv ta te th tl tlh tr uk ur vi zh_CN zh_HK zh_TW'
inherit l10n

python_prepare_all() {
	eapply "${FILESDIR}/revert-erroneous-commit.patch"

	local args=(
		-e 's|build_libtorrent = True|build_libtorrent = False|'
		-e "/Compiling po file/a \\\tuptoDate = False"
	)
	sed -i "${args[@]}" \
        -- 'setup.py' || die
	args=(
		-e 's|"new_release_check": True|"new_release_check": False|'
		-e 's|"check_new_releases": True|"check_new_releases": False|'
		-e 's|"show_new_releases": True|"show_new_releases": False|'
	)
	sed -i "${args[@]}" \
        -- 'deluge/core/preferencesmanager.py' || die

	local loc_dir='deluge/i18n' loc_pre='' loc_post='.po'
	l10n_find_plocales_changes "${loc_dir}" "${loc_pre}" "${loc_post}"
	rm_loc() {
		rm -vf "${loc_dir}/${loc_pre}${1}${loc_post}" || die
	}
	l10n_for_each_disabled_locale_do rm_loc

	distutils-r1_python_prepare_all
}

_distutils-r1_create_setup_cfg() {
	# bug 531370: deluge has its own plugin system. No need to relocate its egg info files.
	# Override this call from the distutils-r1 eclass.
	# This does not respect the distutils-r1 API. DO NOT copy this example.
	:
}

python_install_all() {
	distutils-r1_python_install_all

	local paths=()

	if use daemon ; then
		newinitd "${FILESDIR}/deluged.init" 'deluged'
		newconfd "${FILESDIR}/deluged.conf" 'deluged'
	else
		paths=(
			"${ED}/usr/bin/deluged"
			"${ED}/usr/share/man/man1"/deluged.*
		)
		rm -rvf "${paths[@]}" || die
	fi

	if use webui ; then
		newinitd "${FILESDIR}/deluge-web.init" 'deluge-web'
		newconfd "${FILESDIR}/deluge-web.conf" 'deluge-web'
	else
		paths=(
			"${ED}/usr/bin/deluge-web"
			"${ED}/usr"/lib*/py*/*-packages/deluge/ui/web/
			"${ED}/usr/share/man/man1"/deluge-web.*
		)
		rm -rvf "${paths[@]}" || die
	fi

	if ! use gtk ; then
		paths=(
			"${ED}/usr/bin/deluge-gtk"
			"${ED}/usr"/lib*/py*/*-packages/deluge/ui/gtkui/
			"${ED}/usr/share/applications/deluge-gtk.desktop"
			"${ED}/usr/share/icons"/deluge*
			"${ED}/usr/share/man/man1"/deluge-gtk.*
		)
		rm -rvf "${paths[@]}" || die
	fi

	if ! use console ; then
		paths=(
			"${ED}/usr/bin/deluge-console"
			"${ED}/usr"/lib*/py*/*-packages/deluge/ui/console/*
			"${ED}/usr/share/man/man1"/deluge-console.*
		)
		rm -rvf "${paths[@]}" || die
	fi
}
