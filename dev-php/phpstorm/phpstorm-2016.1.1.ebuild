# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

JBIDEA_PN_PRETTY='PhpStorm'
JBIDEA_URI="webide/PhpStorm-${PV}"

inherit jetbrains-idea

DESCRIPTION="PhpStorm is a commercial, cross-platform IDE for PHP"

JBIDEA_DESKTOP_CATEGORIES=( 'WebDevelopment' )
JBIDEA_DESKTOP_EXTRAS=(
	"MimeType=text/x-php;text/html;" # MUST end with semicolon
)
