# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit flag-o-matic-patched eutils xdg

DESCRIPTION="Tool for ripping and streaming Blu-ray, HD-DVD and DVD discs"
HOMEPAGE="http://www.makemkv.com/"
LICENSE="LGPL-2.1 MPL-1.1 MakeMKV-EULA openssl"

SLOT="0"
MY_P_OSS="${PN}-oss-${PV}"
MY_P_BIN="${PN}-bin-${PV}"
SRC_URI="
	https://www.makemkv.com/download/${MY_P_OSS}.tar.gz
	https://www.makemkv.com/download/${MY_P_BIN}.tar.gz"

KEYWORDS="-* ~amd64"
IUSE="libav qt4 qt5"

CDEPEND_A=(
	"dev-libs/expat"
	"sys-libs/glibc"
	"dev-libs/openssl:0"
	"sys-libs/zlib"

	"!qt5? ( qt4? ("
		"dev-qt/qtcore:4"
		"dev-qt/qtdbus:4"
		"dev-qt/qtgui:4" ") )"
	"qt5? ("
		"dev-qt/qtcore:5"
		"dev-qt/qtdbus:5"
		"dev-qt/qtgui:5"
		"dev-qt/qtwidgets:5" ")"
	"!libav? ( media-video/ffmpeg:0= )"
	"libav? ( media-video/libav:0= )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	# used for http downloads, see 'HTTP_Download()' in '${MY_P_OSS}/libabi/src/httplinux.cpp'
	"net-misc/wget"
)

inherit arrays

declare -A L10N_LOCALES_MAP=(
	['zh']='chi'
	['da']='dan'
	['de']='deu'
	['nl']='dut'
	['fr']='fra'
	['it']='ita'
	['ja']='jpn'
	['no']='nor'
	['fa']='per'
	['pl']='pol'
	['pt_BR']='ptb'
	['es']='spa'
	['sv']='swe'
)
L10N_LOCALES=( ${!L10N_LOCALES_MAP[@]} )
inherit l10n-r1

S="${WORKDIR}/${MY_P_OSS}"

QA_PREBUILT="usr/bin/makemkvcon usr/bin/mmdtsdec"

src_prepare() {
	PATCHES+=( "${FILESDIR}"/${PN}-{makefile,path,sysmacros}.patch )

	# Qt5 always trumps Qt4 if it is available. There are no configure
	# options or variables to control this and there is no publicly
	# available configure.ac either.
	if use qt4; then
		PATCHES+=( "${FILESDIR}"/${PN}-qt4.patch )
	elif use qt5; then
		PATCHES+=( "${FILESDIR}"/${PN}-qt5.patch )
	# else cli only
	fi

	# make these vars global as they're used in src_install()
	declare -g loc_dir="${WORKDIR}/${MY_P_BIN}"/src/share loc_pre='makemkv_' loc_post='.mo.gz'
	l10n_find_changes_in_dir "${loc_dir}" "${loc_pre}" "${loc_post}"

	xdg_src_prepare
}

src_configure() {
	local econf_args=()

	if use qt4 || use qt5 ; then
		econf_args+=( --enable-gui )
	else
		econf_args+=( --disable-gui )
	fi

	econf "${econf_args[@]}"
}

src_compile() {
	emake GCC="$(tc-getCC) ${CFLAGS} ${LDFLAGS}"
}

src_install() {
	### Install OSS components
	dolib.so out/libdriveio.so.0
	dolib.so out/libmakemkv.so.1
	dolib.so out/libmmbd.so.0
	## these symlinks are not installed by upstream
	## TODO: are they still necessary?
	dosym libdriveio.so.0	/usr/$(get_libdir)/libdriveio.so.0.${PV}
	dosym libdriveio.so.0	/usr/$(get_libdir)/libdriveio.so
	dosym libmakemkv.so.1	/usr/$(get_libdir)/libmakemkv.so.1.${PV}
	dosym libmakemkv.so.1	/usr/$(get_libdir)/libmakemkv.so
	dosym libmmbd.so.0		/usr/$(get_libdir)/libmmbd.so
	dosym libmmbd.so.0		/usr/$(get_libdir)/libmmbd.so.0.${PV}

	if use qt4 || use qt5 ; then
		dobin out/${PN}

		local s
		for s in 16 22 32 64 128 ; do
			newicon -s ${s} makemkvgui/share/icons/${s}x${s}/makemkv.png ${PN}.png
		done

		# upstream supplies .desktop file in '${MY_P_OSS}/makemkvgui/share/makemkv.desktop', but
		# the generated one is better
		make_desktop_entry ${PN} MakeMKV ${PN} 'Qt;AudioVideo;Video'
	fi

	### Install binary components
	cd "${WORKDIR}/${MY_P_BIN}" || die

	## install prebuilt bins
	if use amd64 ; then
		dobin bin/amd64/makemkvcon
	else
		die
	fi

	## install misc files
	insinto /usr/share/MakeMKV

	# install profiles
	doins src/share/*.xml
	# install bluray support
	doins src/share/*.jar

	# install locales
	local l locales
	l10n_get_locales locales app on
	for l in ${locales} ; do
		doins "${loc_dir}/${loc_pre}${l}${loc_post}"
	done

	newenvd <(cat <<-_EOF_
			# Automatically generated by ${CATEGORY}/${PF} on $(date --utc -Iminutes)
			#
			# MakeMKV can act as a drop-in replacement for libaacs and libbdplus allowing
			# transparent decryption of a wider range of titles under players like VLC and mplayer.
			#
			LIBAACS_PATH=libmmbd
			LIBBDPLUS_PATH=libmmbd

			_EOF_
		) 20-${PN}-libmmbd
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "While MakeMKV is in beta mode, upstream has provided a license"
	elog "to use if you do not want to purchase one."
	elog "See this forum thread for more information, including the key:"
	elog "  http://www.makemkv.com/forum2/viewtopic.php?f=5&t=1053"
	elog "Note that beta license has an expiration date and you will"
	elog "need to check for newer licenses/releases."
	elog ""
	elog "We previously said to copy default.mmcp.xml to ~/.MakeMKV/. This"
	elog "is no longer necessary and you should delete it from there to"
	elog "avoid warning messages."
	elog ""
	elog "MakeMKV can also act as a drop-in replacement for libaacs and"
	elog "libbdplus, allowing transparent decryption of a wider range of"
	elog "titles under players like VLC and mplayer."
}
