# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit rindeal rpm systemd user

DESCRIPTION="HP SP62413: vcsFPServiceDaemon; driver for the sensor; validity-sensor binary"
HOMEPAGE="https://h20566.www2.hp.com/hpsc/swd/public/detail?sp4ts.oid=5359406&swItemId=ob_125201_1&swEnvOid=2020"
LICENSE="HP-eula"

SLOT="0"
SRC_URI="ftp://ftp.hp.com/pub/softpaq/sp62001-62500/sp62413.tar"

# binaries provided by HP are for amd64 only
KEYWORDS="-* ~amd64"

RDEPEND_A=(
	# libusb-0.1.so.4
	'virtual/libusb:0'
	# libcrypto.so.0.9.8
	# libssl.so.0.9.8
	'dev-libs/openssl:0.9.8'
)

inherit arrays

src_unpack() {
	# unpack tar
	default

	mkdir -p "${S}" || die
	rpm_unpack SP62413/Validity-Sensor-Setup-4.5-118.00.x86_64.rpm "${S}"
}

QA_PRESTRIPPED="usr/sbin/vcsFPService"

src_install() {
	dolib.so 'usr/lib64/libvfsFprintWrapper.so'
	dosbin usr/sbin/* usr/bin/vcsFPService

	dodoc usr/share/doc/packages/validity/README

	systemd_dounit "${FILESDIR}/validity-sensor.service"
	systemd_newtmpfilesd "${FILESDIR}/validity-sensor.tmpfilesd.conf" "validity-sensor.conf"

	exeinto "$(systemd_get_utildir)/system-sleep"
	doexe "${FILESDIR}/65-ValidityService-SuspendResume.sh"
}

pkg_postinst() {
	## vcsFPService will run as 'validity' user
	## 'usb' group is required to be able to communicate with the FP reader
	# enewuser <user> [uid] [shell] [homedir] [groups]
	enewuser validity -1 -1 -1 usb
}
