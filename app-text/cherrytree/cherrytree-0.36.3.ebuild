# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python2_7 )
GH_USER='giuspen'

inherit github python-single-r1 eutils fdo-mime

DESCRIPTION='A hierarchical note taking application'
HOMEPAGE='http://www.giuspen.com/cherrytree'
LICENSE='GPL-3'

SLOT='0'
KEYWORDS='~amd64'

IUSE='nls'

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

PLOCALES='cs de es fr hy it ja nl pl pt_BR ru tr uk zh_CN'

inherit l10n

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	use nls && l10n_find_plocales_changes 'locale' '' '.po'

	default
}

src_compile() {
	local args=
	use nls || args+=' --without-gettext'

	${EPYTHON} setup.py $args build
}

src_install() {
	cd "${S}"

	exeinto '/usr/bin'
	doexe "${PN}"

	insinto "/usr/share/${PN}"
	doins -r 'glade/' 'modules/' 'language-specs/'

	doicon -s scalable "glade/svg/${PN}.svg"
	domenu "linux/${PN}.desktop"
	doman "linux/${PN}.1"

	insinto '/usr/share/mime-info'
	doins "linux/${PN}".{mime,keys}

	insinto '/usr/share/mime/packages'
	doins "linux/${PN}.xml"

	if use nls; then
		ins_loc() {
			insinto "/usr/share/locale/${1}/LC_MESSAGES"
			doins "build/mo/${1}/${PN}.mo"
		}
		l10n_for_each_locale_do ins_loc
	fi
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}
