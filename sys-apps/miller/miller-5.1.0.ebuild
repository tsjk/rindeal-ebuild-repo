# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:johnkerl"
GH_REF="v${PV}"

inherit git-hosting
inherit autotools

DESCRIPTION="A tool like sed, awk, cut, join, and sort for name-indexed data (CSV, JSON, ..)"
HOMEPAGE="http://johnkerl.org/miller ${GH_HOMEPAGE}"
LICENSE="BSD-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE="doc test"

DEPEND="sys-devel/flex"

my_for_each_test_dir() {
	local test_dirs=( c/{reg,unit}_test )
	if use test ; then
		for d in "${test_dirs[@]}" ; do
			epushd "${d}"
			"${@}" || die
			epopd
		done
	fi
}

src_prepare() {
	default

	local sed_args=(
		# respect FLAGS
		-e '/.*FLAGS[^=]*=/ s:(-g|-pg|-O[0-9]) ::g'
	)
	find -type f -name "Makefile.am" | xargs sed -r "${sed_args[@]}" -i --
	assert

	# disable docs rebuilding as they're shipped prebuilt
	sed -e '/SUBDIRS[^=]*=/ s:doc::g' -i -- Makefile.am || die

	# disable building tests automagically
	use test || sed -e '/SUBDIRS[^=]*=/ s:[^ ]*_test::g' -i -- c/Makefile.am || die

	eautoreconf
}

src_test() {
	my_for_each_test_dir emake check
}

src_install() {
	local HTML_DOCS=( $(usev doc) )

	default

	doman 'doc/mlr.1'
}
