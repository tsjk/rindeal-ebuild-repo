# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

JBIJ_PN_PRETTY='PyCharm'
JBIJ_URI="python/pycharm-community-${PV}"

inherit jetbrains-intellij

DESCRIPTION="${JBIJ_PN_PRETTY} is a Python IDE for professional developers"

JBIJ_DESKTOP_EXTRAS=(
	# "MimeType=text/x-php;text/html;" # MUST end with semicolon # TODO
)
