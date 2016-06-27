# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION='Sync files to and from Google Drive, S3, Swift, Cloudfiles, Dropbox, ...'
HOMEPAGE='http://rclone.org/'
LICENSE='MIT'

SLOT='0'
src_uri_base="https://github.com/ncw/rclone/releases/download/v${PV}/rclone-v${PV}-linux"
SRC_URI="
	amd64?	( ${src_uri_base}-amd64.zip )
	arm?	( ${src_uri_base}-arm.zip )
	x86?	( ${src_uri_base}-386.zip )
"

KEYWORDS='-* ~amd64 ~arm ~x86'

RDEPEND="!${CATEGORY}/rclone"

RESTRICT="mirror"

src_unpack() {
	default
	cd "${WORKDIR}"/rclone-*/ || die
	S="${PWD}"
}

inst_d='opt/rclone'
QA_PRESTRIPPED="${inst_d}/bin/rclone"

src_install() {
	into "/${inst_d}"
	dobin rclone
	dosym "/${inst_d}"/bin/rclone /usr/bin/rclone

	doman rclone.1
	dodoc README.*
}
