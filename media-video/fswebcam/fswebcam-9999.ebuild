# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

EGIT_REPO_URI="https://github.com/fsphil/fswebcam.git"
EGIT_BRANCH="master"

inherit git-r3

DESCRIPTION="A neat and simple webcam app"
HOMEPAGE="http://www.sanslogic.co.uk/fswebcam/"
LICENSE="GPL-2"
SRC_URI=""

SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""

DEPEND="media-libs/gd[jpeg,png,truetype]"
RDEPEND="${DEPEND}"
