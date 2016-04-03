# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit git-r3 cmake-utils

DESCRIPTION="Zeal integration plugin for KTextEditor (KDevelop, Kate, KWrite, ...)"
HOMEPAGE="https://github.com/g3ar/ZealSearch"
LICENSE="GPL-2"
EGIT_REPO_URI="https://github.com/g3ar/ZealSearch.git"

SLOT="0"
KEYWORDS="~amd64"

DEPEND="kde-base/kdelibs"
RDEPEND="${DEPEND}"
