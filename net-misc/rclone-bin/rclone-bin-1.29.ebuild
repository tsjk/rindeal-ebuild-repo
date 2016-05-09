# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2
# $Id$

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

KEYWORDS='~amd64 ~arm ~x86'

RDEPEND="
	!${CATEGORY}/rclone"

src_unpack() {
	default
	cd "${WORKDIR}"/rclone-*/ || die
	S="${PWD}"
}

src_install() {
	local inst_d='opt/rclone'

	QA_PREBUILT="${inst_d}/bin/*"

	doman rclone.1

	into "/${inst_d}"
	dobin rclone
	dosym "/${inst_d}"/bin/rclone /usr/bin/rclone

	insinto "/${inst_d}"/doc
	doins README.*
}
