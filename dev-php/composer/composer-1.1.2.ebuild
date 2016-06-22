# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Dependency Manager for PHP"
HOMEPAGE="https://getcomposer.org"
LICENSE="MIT"

SLOT="0"
SRC_URI="https://getcomposer.org/download/${PV}/composer.phar -> ${P}.phar"

KEYWORDS="~amd64 ~arm ~x86"

RDEPEND="dev-lang/php:*"

QA_PREBUILT=".*"

src_unpack() {
	mkdir "${WORKDIR}/${PF}" || die
	cp -v "${DISTDIR}/${P}.phar" "${WORKDIR}/${PF}/composer" || die
}

src_install() {
	dobin "composer"
}
