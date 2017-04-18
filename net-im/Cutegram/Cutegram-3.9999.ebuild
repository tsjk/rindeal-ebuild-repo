# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:Aseman-Land"
# GH_REF="v${PV}-stable" # use only stable versions

inherit git-hosting
inherit qmake-utils

DESCRIPTION="Telegram client by Aseman Land, forked from sigram by Sialan.Labs"
LICENSE="GPL-3"

SLOT="0"

[[ "${PV}" == *9999* ]] || KEYWORDS="~amd64"

CDEPEND_A=(
	"net-libs/libqtelegram-ae"
	"dev-libs/TelegramQML"

	"dev-qt/qtdeclarative:5[widgets,localstorage]" # QtQuick
	"dev-qt/qtquickcontrols:5[widgets]"
	"dev-qt/qtsql:5[sqlite]"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

BUILD_DIR="${WORKDIR}/build"

src_prepare() {
	default

	mkdir -p "${BUILD_DIR}" >/dev/null || die
}

src_configure() {
	cd "${BUILD_DIR}" || die

	local args=(
		PREFIX="${EPREFIX}/usr"
	)

	eqmake5 "${args[@]}" "${S}"
}

src_compile() {
	cd "${BUILD_DIR}" || die

	default
}

src_install() {
	cd "${BUILD_DIR}" || die

	emake INSTALL_ROOT="${D}" install

	cd "${S}" || die

	einstalldocs
}
