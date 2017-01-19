# Copyright 2012-2016 Gentoo Foundation
# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

PYTHON_COMPAT=( python2_7 )
DISTUTILS_SINGLE_IMPL=true

# EXPORT: src_prepare, src_configure, src_compile, src_test, src_install
inherit distutils-r1
# EXPORT: src_prepare, pkg_preinst, pkg_postinst, pkg_postrm
inherit xdg

DESCRIPTION="Metadata Anonymisation Toolkit"
HOMEPAGE="https://mat.boum.org/"
LICENSE="GPL-2"

SLOT="0"
SRC_URI="https://mat.boum.org/files/${P}.tar.xz"

# TODO: arm/arm64 is missing KEYWORD in 'python-distutils-extra'
KEYWORDS="~amd64"
IUSE="+audio +exif gui nls pdf"

CDEPEND=""
DEPEND="${CDEPEND}
	dev-python/python-distutils-extra[${PYTHON_USEDEP}]"
RDEPEND="${CDEPEND}
	dev-python/pygobject:3[${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]

	audio? ( media-libs/mutagen[${PYTHON_USEDEP}] )
	exif? ( media-libs/exiftool )
	gui? ( dev-python/pygtk[${PYTHON_USEDEP}] )
	pdf? (
		dev-python/pdfrw[${PYTHON_USEDEP}]
		dev-python/pycairo[${PYTHON_USEDEP}]
		dev-python/python-poppler[${PYTHON_USEDEP}]
	)
"

src_prepare() {
	distutils-r1_src_prepare
}

python_prepare_all() {
	eapply_user

	# this app contains too many locales to bother to manage them all, thus
	# use nls flag to either keep or remove all
	use nls || erm -r po/*.po

	# fix doc path
	sed -i "s|share/doc/${PN}|share/doc/${PF}|" setup.py || die

	xdg_src_prepare
	distutils-r1_python_prepare_all
}

python_install_all() {
	distutils-r1_python_install_all

	if ! use gui ; then
		epushd "${ED}"
		local rm_locs=(
			usr/bin/${PN}-gui
			usr/share/{applications,man/man1/${PN}-gui*,nautilus-python,pixmaps}
		)
		erm -r "${rm_locs[@]}"
		epopd
	fi
}
