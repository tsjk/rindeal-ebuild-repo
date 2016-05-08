# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

CHROMIUM_LANGS="
	af az be bg bn ca cs da de el en_GB en_US es_419 es es_LA fil fi fr_CA fr fy gd
	he hi hr hu id it ja kk ko lt lv me mk ms nb nl nn pa pl pt_BR pt_PT ro ru
	sk sr sv sw ta te th tr uk uz vi zh_CN zh_TW zu
"
inherit chromium multilib unpacker pax-utils

DESCRIPTION="A fast and secure web browser"
HOMEPAGE="https://www.opera.com/"
LICENSE="OPERA-2014"

SLOT="0"
SRC_URI_BASE="https://get.geo.opera.com/pub/${PN}/desktop/${PV}/linux/${PN}-stable_${PV}"
SRC_URI="
	amd64? ( ${SRC_URI_BASE}_amd64.deb )
	x86? ( ${SRC_URI_BASE}_i386.deb )
"

KEYWORDS="~amd64 ~x86"
IUSE="autoupdate libressl"

RDEPEND="
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	gnome-base/gconf:2
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	net-misc/curl
	net-print/cups
	sys-apps/dbus
	sys-libs/libcap
	x11-libs/cairo
	x11-libs/gdk-pixbuf
	x11-libs/gtk+:2
	x11-libs/libX11
	x11-libs/libXScrnSaver
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXtst
	x11-libs/libnotify
	x11-libs/pango[X]

	!libressl? ( dev-libs/openssl:0 )
	libressl? ( dev-libs/libressl:0 )
"

S="${WORKDIR}"

QA_PREBUILT="*"
OPERA_HOME="opt/${PN}"

src_prepare() {
	eapply_user

	mkdir -p "${OPERA_HOME}"

	# fix libdir
	mv -v -T "usr/lib/x86_64-linux-gnu/${PN}" "${OPERA_HOME}" || die
	rm -r -v "usr/lib" || die

	# fix broken symlink
	ln -f -s "${EROOT}${OPERA_HOME}/${PN}" "usr/bin/${PN}"

	# delete debian-specific files
	rm -r -v "usr/share"/{lintian,menu}

	# unbundle licence
	rm -v "usr/share/doc/opera-stable/copyright" || die

	# fix doc path
	mv -v "usr/share/doc/opera-stable" "usr/share/doc/${PF}" || die

	# delete autoupdater
	use autoupdate || rm -v "${OPERA_HOME}/opera_autoupdate" || die

	pushd "${OPERA_HOME}/localization" > /dev/null || die
	chromium_remove_language_paks
	popd > /dev/null || die

	sed -e 's|^TargetEnvironment|X-&|g' \
		-i "usr/share/applications/${PN}.desktop" || die
}

src_install() {
	mv -v * "${D}" || die

	fperms 4711 "/${OPERA_HOME}"/opera_sandbox
	pax-mark -m "/${OPERA_HOME}"/{opera,opera_sandbox}
}
