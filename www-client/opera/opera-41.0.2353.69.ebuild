# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CHROMIUM_LANGS="
	af az be bg bn ca cs da de el en-GB en-US es-419 es fil fi fr-CA fr fy gd
	he hi hr hu id it ja kk ko lt lv me mk ms nb nl nn pa pl pt-BR pt-PT ro ru
	sk sr sr-ME sv sw ta te th tr uk uz vi zh-CN zh-TW zu
"
inherit rindeal chromium-2 unpacker pax-utils versionator xdg

DESCRIPTION="A fast and secure web browser"
HOMEPAGE="https://www.opera.com/"
LICENSE="OPERA-2014"

SLOT="$(get_version_component_range 1)"
PN_SLOTTED="${PN}${SLOT}"
SRC_URI_BASE="https://get.geo.opera.com/pub/${PN}/desktop/${PV}/linux/${PN}-stable_${PV}"
SRC_URI="
	amd64? ( ${SRC_URI_BASE}_amd64.deb )
"

KEYWORDS="~amd64"
IUSE="autoupdate"

RDEPEND="
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	dev-libs/openssl:0
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
"

S="${WORKDIR}"

QA_PREBUILT="*"
OPERA_HOME="/opt/${PN}/${PN_SLOTTED}"

src_prepare() {
	eapply_user
	xdg_src_prepare

	mkdir -p "${OPERA_HOME#/}" || die

	# delete broken symlink, proper one will be created in src_install()
	rm -v "usr/bin/${PN}" || die

	# fix libdir
	mv -v -T "usr/lib/x86_64-linux-gnu/${PN}" "${OPERA_HOME#/}" || die
	rm -r -v "usr/lib" || die

	## /usr/share mods {
	pushd "usr/share" >/dev/null || die

	# delete debian-specific files
	rm -r -v {lintian,menu} || die

	# unbundle licence
	rm -v "doc/opera-stable/copyright" || die
	# fix doc path
	mv -v "doc"/{opera-stable,${PF}} || die

	# fix icon paths
	local s
	for s in 16 32 48 128 256 ; do
		mv -v "icons/hicolor/${s}x${s}/apps"/{${PN},${PN_SLOTTED}}.png || die
	done
	mv -v "pixmaps"/{${PN},${PN_SLOTTED}}.xpm || die

	# fix mime package path
	mv -v "mime/packages"/{${PN}-stable,${PN_SLOTTED}}.xml || die

	local sedargs=(
		# delete invalid and "unity shell"-specific lines
		-e '/^TargetEnvironment=/d'
		# fix paths in *Exec lines
		-e "/Exec=${PN}/ s@${PN}( |$)@${EPREFIX}${OPERA_HOME}/${PN}\1@"
		# add slot to Name
		-e "s|^Name=${PN}.*|& ${SLOT}|I"
		-e "/^Icon=/ s|.*|Icon=${PN_SLOTTED}|"
	)
	sed -r "${sedargs[@]}" \
		-i -- "applications/${PN}.desktop" || die
	# fix menu entry path
	mv -v "applications"/{${PN},${PN_SLOTTED}}.desktop || die

	popd >/dev/null || die
	## }

	# optionally delete autoupdater
	use autoupdate || { rm -v "${OPERA_HOME#/}/opera_autoupdate" || die ; }

	## locales
	pushd "${OPERA_HOME#/}/localization" >/dev/null || die
	chromium_remove_language_paks
	popd >/dev/null || die
}

src_install() {
	insinto /
	doins -r *

	dosym "${OPERA_HOME}/${PN}" "/usr/bin/${PN_SLOTTED}"

	# fix permissions and pax-mark binaries
	fperms a+x "${OPERA_HOME}/${PN}"
	fperms 4711 "${OPERA_HOME}/opera_sandbox"
	use autoupdate && fperms a+x "${OPERA_HOME}/opera_autoupdate"
	pax-mark -m "${ED}/${OPERA_HOME}"/{opera,opera_sandbox}
}
