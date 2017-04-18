# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GH_RN='github:bobthecow'
GH_REF="v${PV}"

inherit git-hosting composer

DESCRIPTION="REPL for PHP"
HOMEPAGE="http://psysh.org/"
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64 ~arm ~x86"

RDEPEND="${DEPEND}
	dev-lang/php"

src_unpack() {
	git-hosting_src_unpack

	cd "${S}" || die
	ecomposer install --optimize-autoloader --prefer-dist
	./bin/build-vendor || die
}

src_compile() {
	./bin/build-phar || die
}

src_install() {
	newbin 'psysh.phar' 'psysh'
}
