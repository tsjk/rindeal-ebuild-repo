# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

SWORD_MODULE="CzeB21"

inherit sword-module

DESCRIPTION="Czech Bible, Preklad 21. stoleti"
HOMEPAGE="http://crosswire.org/sword/modules/ModInfo.jsp?modName=${SWORD_MODULE}"
LICENSE="freedist"
SRC_URI="http://crosswire.org/ftpmirror/pub/sword/packages/rawzip/${SWORD_MODULE}.zip"

KEYWORDS="~amd64"
