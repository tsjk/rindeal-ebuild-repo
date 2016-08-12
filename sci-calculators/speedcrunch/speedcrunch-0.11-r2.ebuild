# Copyright 1999-2014 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GH_URI="bitbucket/heldercorreia"

inherit cmake-utils git-hosting

DESCRIPTION="Fast and usable calculator for power users"
HOMEPAGE="http://speedcrunch.org/ ${HOMEPAGE}"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64"
IUSE="doc"

DEPEND="
	x11-libs/libX11
	dev-qt/qtcore:4
	dev-qt/qtgui:4"
RDEPEND="${DEPEND}"

L10N_LOCALES=( ar_JO ca_ES cs_CZ de_DE en_GB en_US es_AR es_ES et_EE eu_ES fi_FI fr_FR he_IL hu_HU
	id_ID it_IT ja_JP ko_KR lv_LV nb_NO nl_NL pl_PL pt_BR pt_PT ro_RO ru_RU sv_SE tr_TR uz_UZ vi_VN
	zh_CN )
inherit l10n-r1

S_OLD="${S}"
S="${S_OLD}/src"

src_prepare-locales() {
	local l locales dir='resources/locale' pre='' post='.qm'

	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"

	l10n_get_locales locales app off
	for l in ${locales} ; do
		rm -v -f "${dir}/${pre}${l}${post}" || die
		sed -e "s|<file>locale/${l}.qm</file>||" \
			-i -- resources/speedcrunch.qrc || die
		sed -e "s|map.insert(QString::fromUtf8(\".*, QLatin1String(\"${l}\"));||" \
			-i -- gui/mainwindow.cpp || die
	done
}

src_prepare() {
	cmake-utils_src_prepare

	src_prepare-locales
}

src_install() {
	cmake-utils_src_install

	cd "${S_OLD}" || die

	doicon -s scalable gfx/${PN}.svg
	use doc && dodoc doc/*{.pdf,.odt}
}
