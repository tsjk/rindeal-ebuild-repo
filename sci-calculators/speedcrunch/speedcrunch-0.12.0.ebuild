# Copyright 1999-2014 Gentoo Foundation
# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="bitbucket:heldercorreia"
GH_REF="release-${PV}"

inherit git-hosting
inherit cmake-utils

DESCRIPTION="Fast and usable calculator for power users"
HOMEPAGE="http://speedcrunch.org/ ${GH_HOMEPAGE}"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64"
IUSE="doc"

CDEPEND_A=(
	x11-libs/libX11
	dev-qt/qtcore:4
	dev-qt/qtgui:4
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

L10N_LOCALES=( ar ca_ES cs_CZ da de_DE el en_GB en_US es_AR es_ES et_EE eu_ES fi_FI fr_FR he_IL hu_HU
	id_ID it_IT ja_JP ko_KR lt lv_LV nb_NO nl_NL pl_PL pt_BR pt_PT ro_RO ru_RU sk sv_SE tr_TR uz_Latn_UZ
	vi zh_CN )
inherit l10n-r1

S_OLD="${S}"
S="${S_OLD}/src"

src_prepare-locales() {
	local l locales dir='resources/locale' pre='' post='.qm'

	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"

	l10n_get_locales locales app off
	for l in ${locales} ; do
		erm "${dir}/${pre}${l}${post}"
		sed -e "s|<file>locale/${l}.qm</file>||" \
			-i -- resources/speedcrunch.qrc || die
		sed -e "s|map.insert(QString::fromUtf8(\".*, QLatin1String(\"${l}\"));||" \
			-i -- gui/mainwindow.cpp || die
	done
}

src_prepare() {
	src_prepare-locales

	cmake-utils_src_prepare
}

src_install() {
	cmake-utils_src_install

	cd "${S_OLD}" || die

	doicon -s scalable gfx/${PN}.svg
	use doc && dodoc doc/*.{pdf,odt}
}
