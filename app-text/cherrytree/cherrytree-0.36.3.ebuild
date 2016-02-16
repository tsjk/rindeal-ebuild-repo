# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit python-single-r1 eutils fdo-mime

DESCRIPTION="A hierarchical note taking application"
HOMEPAGE="http://www.giuspen.com/cherrytree"
LICENSE="GPL-3"
SRC_URI="https://github.com/giuspen/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

RESRICT="mirror"
SLOT="0"
KEYWORDS="~amd64"

IUSE="nls"
linguas_=( linguas_{cs,de,es,fr,hy,it,ja,lt,nl,pl,pt_BR,ru,tr,uk,zh_CN} )
IUSE+=" ${linguas_[*]}"

RDEPEND="${PYTHON_DEPS}
	x11-libs/libX11
	>=dev-python/pygtk-2.16:2[${PYTHON_USEDEP}]
	dev-python/pygtksourceview:2[${PYTHON_USEDEP}]
	dev-python/dbus-python[${PYTHON_USEDEP}]
	dev-python/pyenchant[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )
"

pkg_setup()
{
	python-single-r1_pkg_setup
}

src_compile()
{
	local args=
	use nls || args+=" --without-gettext"

	${EPYTHON} setup.py $args build
}

src_install()
{
	cd "${S}"

	exeinto "/usr/bin"
	doexe "${PN}"

	insinto "/usr/share/${PN}"
	doins -r "glade/" "modules/" "language-specs/"

	doicon -s scalable "glade/svg/${PN}.svg"
	domenu "linux/${PN}.desktop"
	doman linux/cherrytree.1

	insinto "/usr/share/mime-info"
	doins "linux/${PN}".{mime,keys}

	insinto "/usr/share/mime/packages"
	doins "linux/cherrytree.xml"

	if use nls; then
		for l in $LINGUAS; do
			insinto "/usr/share/locale/${l}/LC_MESSAGES"
			doins "build/mo/${l}/${PN}.mo"
		done
	fi
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}

