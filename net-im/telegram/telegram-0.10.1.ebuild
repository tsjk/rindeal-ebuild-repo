# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GH_URI='github/telegramdesktop/tdesktop'
GH_REF="v${PV}"
if [ -n "${TELEGRAM_DEBUG}" ] ; then
	GH_FETCH_TYPE=live
	EGIT_CLONE_TYPE=shallow
fi

inherit flag-o-matic xdg eutils qmake-utils git-hosting versionator

DESCRIPTION='Official cross-platorm desktop client for Telegram'
HOMEPAGE="https://desktop.telegram.org/ ${HOMEPAGE}"
LICENSE='GPL-3' # with OpenSSL exception

SLOT='0'

KEYWORDS="~amd64 ~arm"
IUSE='proxy'

CDEPEND_A=(
	'dev-libs/libappindicator:2'	# pspecific_linux.cpp
	'>=media-libs/openal-1.17.2'	# Telegram requires shiny new versions
	'sys-libs/zlib[minizip]'
	# Telegram requires shiny new versions since v0.10.1 and commit
	# https://github.com/telegramdesktop/tdesktop/commit/27cf45e1a97ff77cc56a9152b09423b50037cc50
	# list of required USE flags is taken from `.travis/build.sh`
	'>=media-video/ffmpeg-3.1[mp3,opus,vorbis,wavpack]'
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	'!net-im/telegram-bin'
	'!net-im/telegram-desktop'{,-bin}
)
DEPEND_A=( "${CDEPEND_A[@]}"
	'dev-libs/glib:2'
	'x11-libs/gtk+:2'
	'>=dev-qt/qt-telegram-static-5.6.0_p20160510'	# 5.6.0 is required since 0.9.49
	'virtual/pkgconfig'
	'>=sys-apps/gawk-4.1'	# required for inplace support for .pro files formatter
)

inherit arrays

RESTRICT+=' test'

L10N_LOCALES=( de es it ko nl pt_BR )
inherit l10n-r1

CHECKREQS_DISK_BUILD='1G'
inherit check-reqs

TG_DIR="${S}/Telegram"
TG_PRO="${TG_DIR}/Telegram.pro"

# override qt5 path for use with eqmake5
qt5_get_bindir() { echo "${QT5_PREFIX}/bin" ; }

src_prepare-locales() {
	local l locales dir='Resources/langs' pre='lang_' post='.strings'
	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"
	l10n_get_locales locales app off
	for l in ${locales} ; do
		rm -v -f "${dir}/${pre}${l}${post}" || die
		sed -e "\|${pre}${l}${post}|d" \
			-i -- "${TG_PRO}" 'Resources/telegram.qrc' || die
	done
}

src_prepare-delete_and_modify() {
	local args

	## patch "${TG_PRO}"
	args=(
		# delete any references to local includes/libs
		-e 's|^(.*[^ ]*/usr/local/[^ \\]* *\\?)|# local includes/libs # \1|'
		# delete any hardcoded libs
		-e 's|^(.*LIBS *\+= *-l.*)|# hardcoded libs # \1|'
		# delete refs to bundled Google Breakpad
		-e 's|^(.*/breakpad.*)|# Google Breakpad # \1|'
		# delete refs to bundled minizip, Gentoo uses it's own patched version
		-e 's|^(.*/minizip.*)|# minizip # \1|'
		# delete CUSTOM_API_ID defines, use default ID
		-e 's|^(.*CUSTOM_API_ID.*)|# CUSTOM_API_ID # \1|'
		# remove hardcoded flags, but do not remove `$$PKG_CONFIG ...` appends
		-e 's|^(.*QMAKE_[A-Z]*FLAGS(_[A-Z]*)* *.= *-.*)|# hardcoded flags # \1|'
		# use release versions
		-e 's:(.*)Debug(Style|Lang)(.*):\1Release\2\3 # Debug -> Release Style/Lang:g'
		-e 's|(.*)/Debug(.*)|\1/Release\2 # Debug -> Release|g'
		# dee is not used
		-e 's|^(.*dee-1.0.*)|# dee not used # \1|'
	)
	sed -r "${args[@]}" \
		-i -- "${TG_PRO}" || die

	## lzma is not used when TDESKTOP_DISABLE_AUTOUPDATE is defined
	sed -r -e 's|^(.*<lzma\.h>.*)|// lzma not used // \1|' -i -- SourceFiles/autoupdater.cpp || die
	sed -r -e 's|^(.*liblzma.*)|# lzma not used # \1|' -i -- "${TG_PRO}" || die
}

src_prepare-appends() {
	# make sure there is at least one empty line at the end before adding anything
	echo >> "${TG_PRO}"

	printf '%s\n\n' '# --- EBUILD APPENDS BELOW ---' >> "${TG_PRO}" || die

	## add corrected dependencies back
	local deps=(
		minizip # upstream uses bundled copy
	)
	local libs=( "${deps[@]}"
		xkbcommon # upstream links xkbcommon statically
	)
	local includes=( "${deps[@]}" )

	local l i
	for l in "${libs[@]}" ; do
		echo "PKGCONFIG += ${l}" >>"${TG_PRO}" || die
	done
	for i in "${includes[@]}" ; do
		printf 'QMAKE_CXXFLAGS += `%s %s`\n' '$$PKG_CONFIG --cflags-only-I' "${i}" >>"${TG_PRO}" || die
	done
}

src_prepare() {
	xdg_src_prepare

	cd "${TG_DIR}" || die

	rm -rf *.*proj*		|| die # delete Xcode/MSVS files
	rm -rf ThirdParty	|| die # prevent accidentically using something from there

	## determine which qt-telegram-static version should be used
	if [ -z "${QT_TELEGRAM_STATIC_SLOT}" ] ; then
		local qtstatic='dev-qt/qt-telegram-static'
		local qtstatic_PVR="$(best_version "${qtstatic}" | sed "s|.*${qtstatic}-||")"
		local qtstatic_PV="${qtstatic_PVR%%-*}" # strip revision
		declare -g QT_VER="${qtstatic_PV%%_p*}" QT_PATCH_DATE="${qtstatic_PV##*_p}"
		declare -g QT_TELEGRAM_STATIC_SLOT="${QT_VER}-${QT_PATCH_DATE}"
	else
		einfo "Using QT_TELEGRAM_STATIC_SLOT from environment - '${QT_TELEGRAM_STATIC_SLOT}'"
		declare -g QT_VER="${QT_TELEGRAM_STATIC_SLOT%%-*}" QT_PATCH_DATE="${QT_TELEGRAM_STATIC_SLOT##*-}"
	fi

	echo
	einfo "${P} is going to be linked with 'Qt ${QT_VER} (p${QT_PATCH_DATE})'"
	echo

	# WARNING: QT5_PREFIX path depends on what qt-telegram-static ebuild uses
	declare -g QT5_PREFIX="${EPREFIX}/opt/qt-telegram-static/${QT_VER}/${QT_PATCH_DATE}"
	[ -d "${QT5_PREFIX}" ] || die "QT5_PREFIX dir doesn't exist: '${QT5_PREFIX}'"

	readonly QT_TELEGRAM_STATIC_SLOT QT_VER  QT_PATCH_DATE QT5_PREFIX

	# This formatter converts multiline var defines to multiple lines.
	# Such .pro files are then easier to debug and modify in src_prepare-delete_and_modify().
	gawk -f "${FILESDIR}/format_pro.awk" -i inplace -- *.pro || die

	src_prepare-locales
	src_prepare-delete_and_modify
	src_prepare-appends
}

src_configure() {
	## add flags previously stripped from "${TG_PRO}"
	append-cxxflags '-fno-strict-aliasing' -std=c++14
	# `append-ldflags '-rdynamic'` was stripped because it's used probably only for GoogleBreakpad
	# which is not supported anyway

	# care a little less about the unholy mess
	append-cxxflags '-Wno-unused-'{function,parameter,variable,but-set-variable}
	append-cxxflags '-Wno-switch'

	# prefer patched qt
	export PATH="$(qt5_get_bindir):${PATH}"

	# available since https://github.com/telegramdesktop/tdesktop/commit/562c5621f507d3e53e1634e798af56851db3d28e
	export QT_TDESKTOP_VERSION="${QT_VER}"
	export QT_TDESKTOP_PATH="${QT5_PREFIX}"

	(	# disable updater
		echo 'DEFINES += TDESKTOP_DISABLE_AUTOUPDATE'

		# disable google-breakpad support
		echo 'DEFINES += TDESKTOP_DISABLE_CRASH_REPORTS'

		# disable .desktop file generation
		echo 'DEFINES += TDESKTOP_DISABLE_DESKTOP_FILE_GENERATION'

		# https://github.com/telegramdesktop/tdesktop/commit/0b2bcbc3e93a7fe62889abc66cc5726313170be7
		$(usex proxy 'DEFINES += TDESKTOP_DISABLE_NETWORK_PROXY' '')

		# disable registering `tg://` scheme from within the app
		echo 'DEFINES += TDESKTOP_DISABLE_REGISTER_CUSTOM_SCHEME'

		# remove Unity support
		echo 'DEFINES += TDESKTOP_DISABLE_UNITY_INTEGRATION'
	) >>"${TG_PRO}" || die
}

my_eqmake5() {
	local args=(
		CONFIG+='release'
	)
	eqmake5 "${args[@]}" "$@"
}

src_compile() {
	local d module

	for module in style numbers ; do	# order of modules matters
		d="${S}/Linux/obj/codegen_${module}/Release"
		mkdir -v -p "${d}" && cd "${d}" || die

		elog "Building: ${PWD/${S}\/}"
		my_eqmake5 "${TG_DIR}/build/qmake/codegen_${module}/codegen_${module}.pro"
		emake
	done

	for module in Lang ; do		# order of modules matters
		d="${S}/Linux/ReleaseIntermediate${module}"
		mkdir -v -p "${d}" && cd "${d}" || die

		elog "Building: ${PWD/${S}\/}"
		my_eqmake5 "${TG_DIR}/Meta${module}.pro"
		emake
	done

	d="${S}/Linux/ReleaseIntermediate"
	mkdir -v -p "${d}" && cd "${d}" || die

	elog "Preparing the main build ..."
	elog "Ignore the warnings/errors below"
	# this qmake will fail to find "${TG_DIR}/GeneratedFiles/*", but it's required for ...
	my_eqmake5 "${TG_PRO}"
	# ... this make, which will generate those files
	local targets=( $( awk '/^PRE_TARGETDEPS *\+=/ { $1=$2=""; print }' "${TG_PRO}" ) )
	(( ${#targets[@]} )) || die
	emake ${targets[@]}

	# now we have everything we need, so let's begin!
	elog "Building Telegram ..."
	my_eqmake5 "${TG_PRO}"
	emake
}

src_install() {
	newbin "${S}/Linux/Release/Telegram" "${PN}"

	local s
	for s in 16 32 48 64 128 256 512 ; do
		newicon -s ${s} "${TG_DIR}/Resources/art/icon${s}.png" "${PN}.png"
	done

	local make_desktop_entry_args
	make_desktop_entry_args=(
		"${EPREFIX}/usr/bin/${PN} -- %u"	# exec
		"Telegram Desktop"	# name
		"${PN}"		# icon
		'Network;InstantMessaging;Chat;'	# categories
	)
	make_desktop_entry_extras=(
		'MimeType=x-scheme-handler/tg;'
		'StartupWMClass=Telegram'
	)
	make_desktop_entry "${make_desktop_entry_args[@]}" \
		"$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"

	einstalldocs
}
