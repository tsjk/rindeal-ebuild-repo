# Copyright 1999-2015 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_URI="github/Aseman-Land"
GH_REF="v${PV}"

inherit git-hosting
inherit qmake-utils
inherit multibuild

DESCRIPTION="Telegram API tools for QtQML and Qml"
LICENSE="GPL-3"

SLOT="0"

[[ "${PV}" == *9999* ]] || KEYWORDS="~amd64"
IUSE=""

CDEPEND_A=(
# 	QT += qml quick sql xml multimedia

# 'qt5-base' 'qt5-declarative' 'qt5-multimedia'
#          'qt5-webkit' 'qt5-imageformats' 'qt5-graphicaleffects'
#          'qt5-quickcontrols' 'libqtelegram-ae'

	"dev-qt/qtqml:5"
	"dev-qt/qtsql:5[sqlite]"
	"dev-qt/multimedia:5"
	"dev-qt/qtxml:5"
# 	"dev-qt/qtimageformats:5"
	# TODO: ...

	"sys-libs/zlib"
	"dev-libs/openssl:="
	"net-libs/libqtelegram-ae:="
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
)
RDEPEND="${CDEPEND}"

# TODO: convert variants to USE-flags
MULTIBUILD_VARIANTS=( lib plugin )

src_prepare() {
	default

	sed -e "/LIBS *+=.*-lssl/ s|-lssl -lcrypto -lz|$(pkg-config --libs-only-l openssl zlib)|" \
		-i -- "${PN,,}.pri" || die

	# fix lib path
	sed "s|lib/\$\$LIB_PATH|$(get_libdir)|" -i -- "${PN,,}.pro" || die
}

my_multibuild_foreach_variant() {
	run__() {
		mkdir -p "${BUILD_DIR}" >/dev/null
		epushd "${BUILD_DIR}"

		"$@" || die

		epopd
	}

	multibuild_foreach_variant run__ "$@"
	unset -f run__
}

src_configure() {
	my_multi_configure() {
		local myeqmake5args=(
			PREFIX="${EPREFIX}/usr"
			BUILD_MODE+="${MULTIBUILD_VARIANT}"

			OPENSSL_LIB_DIR="$(pkg-config --libs-only-L openssl)"
			OPENSSL_INCLUDE_PATH="$(pkg-config --cflags-only-I openssl)"

# 			LIBQTELEGRAM_INCLUDE_PATH
# 			LIBQTELEGRAM_LIB_DIR

	# TELEGRAMQML_LIB_DIR
	# TELEGRAMQML_INCLUDE_PATH
		)
		eqmake5 "${myeqmake5args[@]}" -r "${S}"
	}

	my_multibuild_foreach_variant my_multi_configure
}

src_compile() {
	my_multi_compile() {
		emake
	}
	my_multibuild_foreach_variant my_multi_compile
}

src_install() {
	my_multi_install() {
		emake INSTALL_ROOT="${D}" install
	}
	my_multibuild_foreach_variant my_multi_install

	einstalldocs
}
