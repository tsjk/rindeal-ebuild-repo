# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

PYTHON_COMPAT=( python2_7 )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 eutils systemd user

DESCRIPTION="BitTorrent client with a client/server model"
HOMEPAGE="http://deluge-torrent.org/"
LICENSE="GPL-2"
SRC_URI="http://download.deluge-torrent.org/source/${P}.tar.bz2"

KEYWORDS="~amd64 ~arm"
SLOT="0"

IUSE="console +daemon geoip +gtk +libnotify +setproctitle +sound webui"
REQUIRED_USE="${PYTHON_REQUIRED_USE}
	sound? ( gtk ) libnotify? ( gtk )
	|| ( console daemon gtk webui )"
LANGS=(af ar ast be bg bn bs ca cs cy da de el en_AU en_CA en_GB eo es et eu fa fi fo fr fy ga gl
	he hi hr hu id is it ja ka kk km kn ko ku ky la lb lt lv mk ml ms nb nds nl nn oc pl
	pt pt_BR ro ru si sk sl sr sv ta te th tl tlh tr uk ur vi zh_CN zh_HK zh_TW)
for l in "${LANGS[@]}" ; do
    IUSE+=" linguas_${l}"
done

CDEPEND="daemon? ( >=net-libs/libtorrent-rasterbar-0.14.9[python] )"
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
		sound? ( dev-python/pygame[${PYTHON_USEDEP}] )
		dev-python/pygobject:2[${PYTHON_USEDEP}]
		>=dev-python/pygtk-2.12[${PYTHON_USEDEP}]
		gnome-base/librsvg
		libnotify? ( dev-python/notify-python[${PYTHON_USEDEP}] )
	)
	setproctitle? ( dev-python/setproctitle[${PYTHON_USEDEP}] )
	webui? ( dev-python/mako[${PYTHON_USEDEP}] )"

python_prepare_all() {
	eapply "${FILESDIR}/revert-erroneous-commit.patch"

	local args=(
		-e 's|build_libtorrent = True|build_libtorrent = False|'
		-e "/Compiling po file/a \\\tuptoDate = False"
	)
	sed -i "${args[@]}" -- 'setup.py' || die
	args=(
		-e 's|"new_release_check": True|"new_release_check": False|'
		-e 's|"check_new_releases": True|"check_new_releases": False|'
		-e 's|"show_new_releases": True|"show_new_releases": False|'
	)
	sed -i "${args[@]}" -- 'deluge/core/preferencesmanager.py' || die

	for l in "${LANGS[@]}" ;do
		has ${l} ${LINGUAS} || rm -vf deluge/i18n/${l}.po
	done

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

	if use daemon ;then
		newinitd "${FILESDIR}"/deluged.init deluged
		newconfd "${FILESDIR}"/deluged.conf deluged
		systemd_newunit "${FILESDIR}"/deluged.service deluged.service
		systemd_install_serviced "${FILESDIR}"/deluged.service.conf
	else
		rm -rvf "${D}"/usr/bin/deluged "${D}"/usr/share/man/man1/deluged.*
	fi

	if use webui ;then
		newinitd "${FILESDIR}"/deluge-web.init deluge-web
		newconfd "${FILESDIR}"/deluge-web.conf deluge-web
		systemd_newunit "${FILESDIR}"/deluge-web.service deluge-web.service
		systemd_install_serviced "${FILESDIR}"/deluge-web.service.conf
	else
		rm -rvf "${D}"/usr/bin/deluge-web "${D}"/usr/lib*/python*/*-packages/deluge/ui/web/ \
		"${D}"/usr/share/man/man1/deluge-web.*
	fi

	if ! use gtk ;then
		rm -rvf "${D}"/usr/bin/deluge-gtk "${D}"/usr/lib*/python*/*-packages/deluge/ui/gtkui/ \
			"${D}"/usr/share/applications/deluge-gtk.desktop "${D}"/usr/share/icons/deluge* \
			"${D}"/usr/share/man/man1/deluge-gtk.*
	fi

	if ! use console ;then
		rm -rvf "${D}"/usr/bin/deluge-console "${D}"/usr/lib*/python*/*-packages/deluge/ui/console/* \
		"${D}"/usr/share/man/man1/deluge-console.*
	fi
}
