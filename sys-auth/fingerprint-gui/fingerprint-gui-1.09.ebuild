# Copyright 1999-2015 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit rindeal eutils multilib qmake-utils udev user

DESCRIPTION="Use Fingerprint Devices with Linux"
HOMEPAGE="http://www.ullrich-online.cc/fingerprint/"
LICENSE="GPL-3"

SLOT="0"
SRC_URI="http://www.ullrich-online.cc/fingerprint/download/${P}.tar.gz"

KEYWORDS="~amd64"
IUSE="+upekbsapi"

CDEPEND_A=(
	dev-qt/qtcore:4

	app-crypt/qca:2[openssl,qt4(+)]
	sys-auth/libfprint
	sys-auth/polkit-qt[qt4(+)]
	sys-libs/pam
	x11-libs/libfakekey

	!sys-auth/thinkfinger
)
DEPEND_A=( "${CDEPEND_A[@]}"
	'virtual/pkgconfig' )
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

src_prepare() {
	default

	# fix EPREFIX in POLKIT1DIR var
	sed -e 's|POLKIT1DIR = "/usr/share/polkit-1"|POLKIT1DIR = $${PREFIX}/share/polkit-1|' \
		-i -- bin/fingerprint-rw/fingerprint-rw.pro || die
	# fix EPREFIX in XDGDIR var
	sed -e "s|XDGDIR = /etc/xdg|XDGDIR = ${EPREFIX}/etc/xdg|" \
		-i -- bin/fingerprint-polkit-agent/fingerprint-polkit-agent.pro || die
	# pkg-config --libs
	sed -e "s|LIBS += .*|LIBS += $(pkg-config --libs libusb-1.0 libfprint x11 polkit-qt-agent-1 polkit-qt-core-1)|" \
		-i -- bin/fingerprint-polkit-agent/fingerprint-polkit-agent.pro || die
	# fix EPREFIX
	sed -e "s|target.path  = /|target.path  = ${EPREFIX}/|" \
		-i -- bin/fingerprint-pam/fingerprint-pam.pro || die
	# pkg-config --libs
	sed -e "s|LIBS += -lX11|LIBS += $(pkg-config --libs x11)|" \
		-i -- bin/fingerprint-pam/fingerprint-pam.pro || die
	# pkg-config --libs
	sed -e "s|LIBS += -lusb-1.0 -lfprint|LIBS += $(pkg-config --libs libusb-1.0 libfprint)|" \
		-i -- bin/fingerprint-identifier/fingerprint-identifier.pro || die
	# pkg-config --libs
	sed -e "s|LIBS += -lusb-1.0 -lfprint -lfakekey -lX11 -ldl -lqca|$(pkg-config --libs libusb-1.0 libfprint x11 libfakekey qca2) -ldl|" \
		-i -- bin/fingerprint-helper/fingerprint-helper.pro || die
	# EPREFIX
	sed -e "s|\(INSTALL_ROOT.\)/etc|\1/${EPREFIX}/etc|g" \
		-i -- bin/fingerprint-helper/fingerprint-helper.pro || die
	# EPREFIX
	sed -e "s|directory.path  = /var/lib|directory.path  = ${EPREFIX}/var/lib|" \
		-i -- bin/fingerprint-gui/fingerprint-gui.pro || die
	# pkg-config --libs
	sed -e "s|LIBS += -lusb-1.0 -lfprint -lpam -ldl -lqca|$(pkg-config --libs libusb-1.0 libfprint qca2) -lpam -ldl|" \
		-i -- bin/fingerprint-gui/fingerprint-gui.pro || die

	# fix udev rules path
	sed -e "s:/etc/udev/rules.d:\"$(get_udevdir)\"/rules.d:g" \
		-i bin/fingerprint-helper/fingerprint-helper.pro || die
	# change 'plugdev' group to 'fingerprint'
	sed -e 's:GROUP="plugdev":GROUP="fingerprint":' \
		-i bin/fingerprint-helper/92-fingerprint-gui-uinput.rules \
		-i upek/91-fingerprint-gui-upek.rules || die
}

src_configure() {
	local myeqmakeargs=(
		PREFIX="${EPREFIX}/usr"
		LIB="$(get_libdir)"
		LIBEXEC='libexec'	# libexec dir name
		LIBPOLKIT_QT=LIBPOLKIT_QT_1_1
	)
	eqmake4 "${myeqmakeargs[@]}"
}

src_install() {
	export INSTALL_ROOT="${D}" # FIXME: ?? submakes need it as well, re-install fails otherwise.
	emake -j1 install

	doicon src/res/fingerprint-gui.png

	## FIXME
	rm -r "${ED}/usr/share/doc/${PN}" || die

	if use upekbsapi ; then
		use amd64 && dolib.so upek/lib64/libbsapi.so*
		udev_dorules upek/91-fingerprint-gui-upek.rules
		insinto /etc
		doins upek/upek.cfg
	fi

	HTML_DOCS=( doc/* )
	einstalldocs
}

QA_SONAME="/usr/lib/libbsapi.so.* /usr/lib64/libbsapi.so.*"
QA_PRESTRIPPED="/usr/lib/libbsapi.so.* /usr/lib64/libbsapi.so.*"
QA_FLAGS_IGNORED="/usr/lib/libbsapi.so.* /usr/lib64/libbsapi.so.*"

pkg_postinst() {
	# devices and users of these device shoould be in this group
	enewgroup fingerprint

	einfo "Fixing permisisons of fingerprints..."
	chown -R root:root -- "${EROOT}/var/lib/${PN}"
	find "${EROOR}/var/lib/${PN}" -type d | xargs chmod 750 --
	find "${EROOT}/var/lib/${PN}" -type f | xargs chmod 600 --

	udev_reload
}

#  FIXME
DOC_CONTENTS="Please take a thorough look a the Install-step-by-step.html
in /usr/share/doc/${PF} for integration with pam/polkit/...
Hint: You may want
   auth        sufficient  pam_fingerprint-gui.so
in /etc/pam.d/system-auth

There are udev rules to enforce group fingerprint on the reader device
Please put yourself in that group and re-trigger the udev rules."
