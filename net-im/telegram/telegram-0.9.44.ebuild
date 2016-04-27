# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

GH_REPO='telegramdesktop/tdesktop'
GH_TAG="v${PV}"

inherit flag-o-matic check-reqs fdo-mime eutils qmake-utils github

DESCRIPTION='Desktop client of Telegram, the messaging app'
HOMEPAGE='https://telegram.org'
LICENSE='GPL-3' # with OpenSSL exception

SLOT='0'

RESTRICT+=' test'
KEYWORDS='~amd64 ~x86'
IUSE=''
REQUIRED_USE=''

RDEPEND=(
	'dev-libs/libappindicator:3'
	'>=media-libs/openal-1.17.2'	# Telegram requires shiny new versions
	'sys-libs/zlib[minizip]'
	'virtual/ffmpeg[opus]'
)
DEPEND=( "${RDEPEND[@]}"
	'~dev-qt/qt-telegram-static-5.5.1_p20160406'
	'virtual/pkgconfig'
)

DEPEND="${DEPEND[*]}"
RDEPEND="${RDEPEND[*]}"

PLOCALES='de es it ko nl pt_BR'
inherit l10n

CHECKREQS_DISK_BUILD='800M'

tg_dir="${S}/Telegram"
tg_pro="${tg_dir}/Telegram.pro"
# this path must be in sync with dev-qt/qt-telegram-static ebuild
qt_dir="${EROOT}opt/telegram-qtstatic"

# override qt5 path for use with eqmake5
qt5_get_bindir() {
	echo "${qt_dir}/bin"
}

src_prepare-locales() {
	l10n_find_plocales_changes 'Resources/langs' 'lang_' '.strings'
	rm_loc() {
		rm -v -f "Resources/langs/lang_${1}.strings" || return 1
		sed -i "\|lang_${1}.strings|d" \
			-- "${tg_pro}" 'Resources/telegram.qrc' || return 2
	}
	l10n_for_each_disabled_locale_do rm_loc
}

src_prepare-delete_and_modify() {
	local args=

	## patch "${tg_pro}"
	args=(
		# delete any references to local includes/libs
		-e '\|/usr/local/|d'
		# delete any hardcoded includes
		-e '\|INCLUDEPATH *\+= *"/usr|d'
		# delete any hardcoded libs
		-e '\|LIBS *\+= *-l|d'
		# delete refs to bundled Google Breakpad
		-e '\|breakpad/src|d'
		# delete refs to bundled minizip, Gentoo uses it's own patched version
		-e '\|minizip|d'
		# delete CUSTOM_API_ID defines, use default ID
		-e '\|CUSTOM_API_ID|d'
		# remove hardcoded flags
		-e '\|QMAKE_[A-Z]*FLAGS|d'
		# use release versions
		-e 's:Debug(Style|Lang):Release\1:g'
	)
	sed -i -r "${args[@]}" \
		-- "${tg_pro}" || die

	## change references to static Qt dir
	sed -i -r "s|[^ ]*Libraries/QtStatic/qtbase/([^ \"\\]*)|${qt_dir}/\1|g" \
		-- *'.pro' || die
	sed -i -r 's|".*src/gui/text/qfontengine_p.h"|<private/qfontengine_p.h>|' \
		-- 'SourceFiles/ui/text/'{text.h,text_block.h} || die

	## nuke libunity references
	args=(
		# ifs cannot be deleted, so replace them with 0
		-e 's|if *\( *_psUnityLauncherEntry *\)|if(0)|'
		# this is probably not needed, but anyway
		-e 's|noTryUnity *= *false,|noTryUnity = true,|'
		# delete includes
		-e '\|unity\.h|d'
		# delete various refs
		-e '\|f_unity|d'
		-e '\|ps_unity_|d'
		-e '\|UnityLauncher|d'
	)
	sed -i -r "${args[@]}" \
		-- 'SourceFiles/pspecific_linux.cpp' || die
}

src_prepare-appends() {
	# make sure there is at least one empty line at the end before adding anything
	echo >> "${tg_pro}"

	## add corrected dependencies back
	local deps=( 'appindicator3-0.1' 'minizip')
	local libs=( "${deps[@]}"
		'lib'{avcodec,avformat,avutil,swresample,swscale}
		'openal' 'openssl' 'zlib' )
	local includes=( "${deps[@]}" )

	"$(tc-getPKG_CONFIG)" --libs "${libs[@]}" | \
		awk '{print "LIBS += ",$0}' >> "${tg_pro}"
	assert
	"$(tc-getPKG_CONFIG)" --cflags-only-I "${includes[@]}" | \
		sed -r 's| *-I([^ ]*) *|INCLUDEPATH += "\1"\n|g' >> "${tg_pro}"
	assert

	(
		# disable updater
		echo 'DEFINES += TDESKTOP_DISABLE_AUTOUPDATE'

		# disable registering `tg://` scheme from within the app
		echo 'DEFINES += TDESKTOP_DISABLE_REGISTER_CUSTOM_SCHEME'

		# https://github.com/telegramdesktop/tdesktop/commit/0b2bcbc3e93a7fe62889abc66cc5726313170be7
		# echo 'DEFINES += TDESKTOP_DISABLE_NETWORK_PROXY'

		# disable google-breakpad support
		echo 'DEFINES += TDESKTOP_DISABLE_CRASH_REPORTS'
	) >> "${tg_pro}" || die
}

src_prepare() {
	cd "${tg_dir}" || die

	rm -rf *.*proj* || die	# delete Xcode/MSVS files

	src_prepare-locales
	src_prepare-delete_and_modify
	src_prepare-appends

	cd "${S}" || die
	eapply_user
}

src_configure() {
	## add flags previously stripped from "${tg_pro}"
	append-cxxflags '-fno-strict-aliasing'
	# `append-ldflags '-rdynamic'` was stripped because it's used probably only for GoogleBreakpad
	# which is not supported anyway

	# a bit more silence
	append-cxxflags '-Wno-unused-'{function,parameter,variable,but-set-variable}

	# prefer patched qt
	export PATH="$(qt5_get_bindir):${PATH}"
}

src_compile() {
	local d= mode='release'

	for module in Style Lang ; do	# order of modules matters
		d="${S}/Linux/${mode^}Intermediate${module}"
		mkdir -p "${d}" && cd "${d}" || die

		elog "Building: ${PWD/${S}\/}"
		eqmake5 CONFIG+="${mode}" "${tg_dir}/Meta${module}.pro"
		emake
	done

	d="${S}/Linux/${mode^}Intermediate"
	mkdir -p "${d}" && cd "${d}" || die

	elog "Preparing the main build ..."
	# this qmake will fail to find "${tg_dir}/GeneratedFiles/*", but it's required for ...
	eqmake5 CONFIG+="${mode}" "${tg_pro}"
	# ... this make, which will generate those files
	local targets=( $( awk '/^PRE_TARGETDEPS *\+=/ { $1=$2=""; print }' "${tg_pro}" ) )
	[ ${#targets[@]} -eq 0 ] && die
	emake ${targets[@]}

	# now we have everything we need, so let's begin!
	elog "Building Telegram ..."
	eqmake5 CONFIG+="${mode}" "${tg_pro}"
	emake
}

src_install() {
	newbin "${S}/Linux/Release/Telegram" "${PN}"

	for s in 16 32 48 64 128 256 512 ; do
		newicon -s ${s} "${tg_dir}/Resources/art/icon${s}.png" "${PN}.png"
	done

	make_desktop_entry_args=(
		"${EROOT}usr/bin/${PN} -- %u"	# exec
		"${PN^}"	# name
		"${PN}"		# icon
		'Network;InstantMessaging;Chat'	# categories
	)
	make_desktop_entry_extras=(
		'MimeType=x-scheme-handler/tg;'
	)
	make_desktop_entry "${make_desktop_entry_args[@]}" \
		"$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"

	einstalldocs
}

pkg_postinst() {
	fdo-mime_desktop_database_update
}
