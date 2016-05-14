# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

JBIJ_PN_PRETTY='IntelliJ IDEA'
JBIJ_URI="idea/ideaIU-${PV}"

inherit jetbrains-intellij

DESCRIPTION="IntelliJ IDEA is a capable and ergonomic Java IDE"

IUSE="android"

src_unpack() {
	local JBIJ_TAR_EXCLUDE=()
	use android || JBIJ_TAR_EXCLUDE+=( 'plugins/android' )

	jetbrains-intellij_src_unpack
}

JBIJ_DESKTOP_EXTRAS=(
	# "MimeType=;" # MUST end with semicolon # TODO
)
