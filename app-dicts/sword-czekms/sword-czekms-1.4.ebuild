# Copyright 2015-2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

SWORD_MODULE="CzeKMS"

inherit sword-module

DESCRIPTION="Czech Preklad KMS Nova smlouva"
HOMEPAGE="http://crosswire.org/sword/modules/ModInfo.jsp?modName=${SWORD_MODULE}"
LICENSE="freedist"
SRC_URI="http://crosswire.org/ftpmirror/pub/sword/packages/rawzip/${SWORD_MODULE}.zip"

KEYWORDS="~amd64"
