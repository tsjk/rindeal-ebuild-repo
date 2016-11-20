# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

inherit eutils
inherit toolchain-funcs
inherit qmake-utils
inherit systemd

DESCRIPTION="IEEE 802.1X/WPA supplicant for secure wireless transfers"
HOMEPAGE="https://w1.fi/wpa_supplicant/"
LICENSE="|| ( GPL-2 BSD )"

SLOT="0"
SRC_URI="https://w1.fi/releases/${P}.tar.gz"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=(
	debug +readline +dbus

	gui qt4 qt5

	+openssl gnutls tls1_1 +tls1_2 smartcard

	driver_atheros driver_hostap driver_macsec_qsa +driver_nl80211 driver_nl80211_qca driver_none
	driver_roboswitch driver_wired driver_wext

	+bgscan_simple bgscan_learn

	wps wps_er wps_nfc wps_strict wps_ufd wps_upnp

	ieee80211ac ieee80211n ieee80211r ieee80211u ieee80211w ieee80211z

	eap-aka eap-aka-prime eap-eke eap-fast eap-gpsk eap-gpsk-sha256 eap-gtc eap-ikev2 eap-leap eap-md5 eap-mschapv2
	eap-otp eap-pax eap-peap eap-psk eap-sake eap-sim eap-tls eap-ttls ieee8021x_eapol pcsc peerkey pkcs12

	+bgscan_simple bgscan_learn

	ap mesh hotspot_2-0 wifi-direct
)

CDEPEND_A=(
	"dbus? ( sys-apps/dbus )"

	"pcsc? ( sys-apps/pcsc-lite )"
	"dev-libs/libnl:3"
	"net-wireless/crda"

	"qt4? ("
		"dev-qt/qtcore:4"
		"dev-qt/qtgui:4"
		"dev-qt/qtsvg:4"
	")"
	"qt5? ("
		"dev-qt/qtcore:5"
		"dev-qt/qtgui:5"
		"dev-qt/qtwidgets:5"
		"dev-qt/qtsvg:5"
	")"
	"readline? ("
		"sys-libs/ncurses:0="
		"sys-libs/readline:0="
	")"
	"openssl? ("
		"dev-libs/openssl:0="
	") !openssl? ("
		"gnutls? ("
			"net-libs/gnutls"
			"dev-libs/libgcrypt:*"
		") !gnutls? ("
			"dev-libs/libtommath"
		")"
	")"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	"eap-fast? ( !gnutls !openssl )"
	"smartcard? ( openssl )"
	"gui? ( || ( qt5 qt4 ) )"
	"driver_nl80211_qca? ( driver_nl80211 )"
	"eap-sim? ( pcsc )"
	"eap-aka? ( pcsc )"
	"eap-aka-prime? ( eap-aka )"
)

inherit arrays

##
# Option is enabled if it's present and has some value, disabled if it's commented or not present.
##
Kconfig_style_config() {
	#param 1 is CONFIG_* item
	#param 2 is what to set it = to, defaulting in y
	local CONFIG_PARAM="${CONFIG_HEADER:-CONFIG_}$1"
	local setting="${2:-y}"

	if [[ "${setting,,}" =~ ^(y(es)?|true|1)$ ]] ; then
		setting='y'
	elif [[ "${setting,,}" =~ ^(no?|false|0)$ ]] ; then
		setting='n'
	fi

	if [[ "${setting}" != 'n' ]] ; then
		echo "${CONFIG_PARAM^^}=${setting}" >> .config || die
	else
		# make sure it's commented out
		sed -e "/${CONFIG_PARAM^^}=/ s|^|#|" -i -- .config || die
		echo "#!${CONFIG_PARAM^^}=" >> .config || die
	fi
}

src_prepare() {
	ALL_CONFIG_OPTIONS=( $( grep -h -o -r -P "(?<=(D| ))CONFIG(_[A-Z0-9]{2,}){1,}(?=[^_A-Z0-9])" | sort -u ) )

	eapply "${FILESDIR}/2.6-quiet-scan-results-message.patch"
	eapply "${FILESDIR}/2.6-less-aggressive-roaming.patch"
	# bug gentoo#320097
	eapply "${FILESDIR}/2.6-do-not-call-dbus-functions-with-NULL-path.patch"

	eapply_user

	epushd "${PN}"

	# People seem to take the example configuration file too literally (bug gentoo#102361)
	sed -i \
		-e "s:^\(opensc_engine_path\):#\1:" \
		-e "s:^\(pkcs11_engine_path\):#\1:" \
		-e "s:^\(pkcs11_module_path\):#\1:" \
		wpa_supplicant.conf || die

	# Change configuration to match Gentoo locations (bug gentoo#143750)
	sed \
		-e "s:/usr/lib/opensc:/usr/$(get_libdir):" \
		-e "s:/usr/lib/pkcs11:/usr/$(get_libdir):" \
		-i -- wpa_supplicant.conf || die

	# systemd entries to D-Bus service files (bug gentoo#372877)
	echo 'SystemdService=wpa_supplicant.service' \
		| tee -a dbus/*.service >/dev/null || die

	epopd # "${PN}"
}

src_configure() {
	# Toolchain setup
	tc-export CC

	epushd "${PN}"

	# copy all uncommented non-config lines
	egrep -v '^(#|CONFIG_|[ \t]*$)' defconfig > .config
	(( $? >= 2 )) && die

	## Basic setup
	Kconfig_style_config CTRL_IFACE unix # TODO: make configurable via variable
	Kconfig_style_config BACKEND file
	Kconfig_style_config LIBNL32
	{	## dbus
		Kconfig_style_config CTRL_IFACE_DBUS		$(usex dbus) # old API
		Kconfig_style_config CTRL_IFACE_DBUS_NEW	$(usex dbus) # new API
		Kconfig_style_config CTRL_IFACE_DBUS_INTRO	$(usex dbus) # introspection
	};{	## debug
		# Enable support for writing debug info to a log file and syslog.
		Kconfig_style_config DEBUG_FILE		$(usex debug)
		Kconfig_style_config DEBUG_SYSLOG	$(usex debug)
	};{	## readline
		# readline/history support for wpa_cli
		Kconfig_style_config READLINE $(usex readline)
		# internal line edit mode for wpa_cli
		Kconfig_style_config WPA_CLI_EDIT $(usex !readline)
	}
	# Enable mitigation against certain attacks against TKIP
	Kconfig_style_config DELAYED_MIC_ERROR_REPORT

	## IEEE80211 standards
	Kconfig_style_config IEEE80211AC	$(usex ieee80211ac)
	Kconfig_style_config IEEE80211N		$(usex ieee80211n)
	Kconfig_style_config IEEE80211R		$(usex ieee80211r)
	Kconfig_style_config INTERWORKING	$(usex ieee80211u)
	Kconfig_style_config IEEE80211W		$(usex ieee80211w)
	Kconfig_style_config TDLS			$(usex ieee80211z)

	## Drivers
	Kconfig_style_config DRIVER_ATHEROS	$(usex driver_atheros)
	Kconfig_style_config DRIVER_HOSTAP	$(usex driver_hostap)
	Kconfig_style_config DRIVER_MACSEC_QCA	$(usex driver_macsec_qsa)
	Kconfig_style_config DRIVER_NL80211	$(usex driver_nl80211)
	Kconfig_style_config DRIVER_NL80211_QCA	$(usex driver_nl80211_qca)
	Kconfig_style_config DRIVER_NONE	$(usex driver_none)
	Kconfig_style_config DRIVER_ROBOSWITCH	$(usex driver_roboswitch)
	Kconfig_style_config DRIVER_WEXT	$(usex driver_wext)
	Kconfig_style_config DRIVER_WIRED	$(usex driver_wired)

	## Authentication methods
	Kconfig_style_config EAP_AKA	$(usex eap-aka)
	Kconfig_style_config EAP_AKA_PRIME	$(usex eap-aka-prime)
	Kconfig_style_config EAP_EKE	$(usex eap-eke)
	Kconfig_style_config EAP_FAST	$(usex eap-fast)
	Kconfig_style_config EAP_GPSK	$(usex eap-gpsk)
	Kconfig_style_config EAP_GPSK_SHA256	$(usex eap-gpsk-sha256)
	Kconfig_style_config EAP_GTC	$(usex eap-gtc)
	Kconfig_style_config EAP_IKEV2	$(usex eap-ikev2)
	Kconfig_style_config EAP_LEAP	$(usex eap-leap)
	Kconfig_style_config EAP_MD5	$(usex eap-md5)
	Kconfig_style_config EAP_MSCHAPV2	$(usex eap-mschapv2)
	Kconfig_style_config EAP_OTP	$(usex eap-otp)
	Kconfig_style_config EAP_PAX	$(usex eap-pax)
	Kconfig_style_config EAP_PEAP	$(usex eap-peap)
	Kconfig_style_config EAP_PSK	$(usex eap-psk)
	Kconfig_style_config EAP_SAKE	$(usex eap-sake)
	Kconfig_style_config EAP_SIM	$(usex eap-sim)
	Kconfig_style_config EAP_TLS	$(usex eap-tls)
	Kconfig_style_config EAP_TTLS	$(usex eap-ttls)
	Kconfig_style_config IEEE8021X_EAPOL	$(usex ieee8021x_eapol)
	Kconfig_style_config PCSC		$(usex pcsc)
	Kconfig_style_config PEERKEY	$(usex peerkey)
	Kconfig_style_config PKCS12		$(usex pkcs12)

	# Background scanning.
	Kconfig_style_config BGSCAN_SIMPLE	$(usex bgscan_simple)
	Kconfig_style_config BGSCAN_LEARN	$(usex bgscan_learn)

	# SSL authentication methods
	use openssl && use gnutls && \
		elog "You have both 'gnutls' and 'openssl' USE flags enabled: defaulting to USE=\"openssl\""
	# fallback order: openssl -> gnutls -> internal
	Kconfig_style_config TLS	$(usex openssl{,} $(usex gnutls{,} internal))
	Kconfig_style_config TLSV11	$(usex tls1_1)
	Kconfig_style_config TLSV12	$(usex tls1_2)
	Kconfig_style_config SMARTCARD	$(usex smartcard)

	## Wi-Fi Protected Setup (WPS)
	Kconfig_style_config WPS		$(usex wps)
	Kconfig_style_config WPS_ER		$(usex wps_er)
	Kconfig_style_config WPS_NFC	$(usex wps_nfc)
	# CONFIG_WPS_OOB -- set by WPS_NFC
	Kconfig_style_config WPS_UFD	$(usex wps_ufd)
	Kconfig_style_config WPS_UPNP	$(usex wps_upnp)
	Kconfig_style_config WPS_STRICT	$(usex wps_strict)

	# Wi-Fi Direct (WiDi)
	Kconfig_style_config P2P			$(usex wifi-direct)
	Kconfig_style_config WIFI_DISPLAY	$(usex wifi-direct)
	Kconfig_style_config MESH	$(usex mesh)
	Kconfig_style_config HS20	$(usex hotspot_2-0) # Hotspot 2.0 (https://en.wikipedia.org/wiki/Hotspot_%28Wi-Fi%29#Hotspot_2.0)
	Kconfig_style_config AP		$(usex ap)

# 	local o unhandled_options=()
# 	for o in "${ALL_CONFIG_OPTIONS[@]}" ; do
# 		if ! grep -q "${o}=" .config ; then
# 			unhandled_options+=( "${o}" )
# 		fi
# 	done
# 	if (( ${#unhandled_options[*]} )) ; then
# 		einfo "Unhandled options:"
# 		printf "%s\n" "${unhandled_options[@]}"
# 	fi

	epopd # "${PN}"

	if use gui ; then
		epushd "${PN}/wpa_gui-qt4"
		eqmake$(usex qt5 5 4) wpa_gui.pro
		epopd
	fi
}

src_compile() {
	emake -C "${PN}" V=1 BINDIR=/usr/sbin

	if use gui ; then
		emake -C "${PN}/wpa_gui-qt4"
	fi
}

src_install() {
	epushd "${PN}"

	dosbin "${PN}"
	dobin wpa_cli wpa_passphrase

	dodoc ChangeLog {eap_testing,todo}.txt README{,-WPS} "${PN}.conf"
	newdoc .config build-config

	# FIXME: not all man-pages are always needed
	doman doc/docbook/*.{5,8}

	systemd_dounit "${FILESDIR}/${PN}.service"
	systemd_dounit "${FILESDIR}/${PN}@.service"
	use dbus && systemd_dounit "${FILESDIR}/${PN}-dbus.service"

	## default config
	insinto "/etc/${PN}"
	doins "${FILESDIR}/${PN}.conf"

	epopd # "${PN}"

	if use gui ; then
		epushd "${PN}/wpa_gui-qt4"

		dobin "wpa_gui"
		doicon -s scalable "icons/wpa_gui.svg"
		make_desktop_entry "wpa_gui" "WPA Supplicant Administration GUI" "wpa_gui" "Qt;Network;"

		epopd
	fi

	if use dbus ; then
		epushd "${PN}/dbus"

		insinto "/etc/dbus-1/system.d"
		newins "dbus-${PN}.conf" "${PN}.conf"

		insinto "/usr/share/dbus-1/system-services"
		doins "fi.epitest.hostap.WPASupplicant.service" "fi.w1.${PN}1.service"

		epopd
	fi
}

pkg_postinst() {
# 	if ! [[ -e "${ROOT}etc/wpa_supplicant/wpa_supplicant.conf" ]] ; then
		elog "If this is a clean installation of wpa_supplicant, you"
		elog "have to create a configuration file named"
		elog "${ROOT}etc/wpa_supplicant/wpa_supplicant.conf"
		elog ""
		elog "An example (not working) configuration file is available for reference in"
		elog "${ROOT}usr/share/doc/${PF}/"
# 	fi

	if [[ -e "${ROOT}etc/wpa_supplicant.conf" ]] ; then
		echo
		ewarn "WARNING: your old configuration file ${ROOT}etc/wpa_supplicant.conf"
		ewarn "needs to be moved to ${ROOT}etc/wpa_supplicant/wpa_supplicant.conf"
	fi
}
