# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

VIRTUALX_REQUIRED='always'

inherit eutils fdo-mime virtualx qmake-utils

DESCRIPTION="Desktop client of Telegram, the messaging app."
HOMEPAGE="https://telegram.org"
LICENSE="GPL-3" # with OpenSSL exception

qt_ver=5.5.1

SRC_URI="(
	https://github.com/telegramdesktop/tdesktop/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://download.qt-project.org/official_releases/qt/${qt_ver%.*}/${qt_ver}/single/qt-everywhere-opensource-src-${qt_ver}.tar.xz
)"

SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror"

IUSE="gtkstyle"

RDEPEND=(
	# deps from arch PKGBUILD
	'virtual/ffmpeg'
	'dev-libs/icu'
	'media-libs/jasper'
	'media-libs/libexif'
	'media-libs/libmng'
	'media-libs/libwebp'
	'x11-libs/libxkbcommon'
	'dev-libs/libinput'
	'net-libs/libproxy'
	'sys-libs/mtdev'
	'=media-libs/openal-9999'
	'x11-libs/libva'
	'media-libs/opus'

	# custom deps
	'x11-libs/gtk+:2'
	'dev-libs/glib:2'
	'app-arch/xz-utils' # lzma
	'dev-util/google-breakpad'
	'sys-libs/zlib[minizip]'
	'virtual/jpeg:*'
	'media-libs/libpng:*'
	'media-libs/freetype'
	'x11-libs/libxcb'
	'dev-libs/libpcre'
	'media-libs/harfbuzz'
)
RDEPEND="${RDEPEND[@]}"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	dev-libs/libappindicator:3
"

S="${WORKDIR}/tdesktop-${PV}"
tg_dir="${S}/Telegram"
tg_pro="${tg_dir}/Telegram.pro"

qtstatic_dir="${WORKDIR}/Libraries/QtStatic"
qt_dir="${WORKDIR}/qt"

# override qt5 path for use with eqmake5
qt5_get_bindir() {
	echo "${qt_dir}/bin"
}

src_unpack() {
	default

	rm -rf "${qtstatic_dir}"
	mkdir -p "$( dirname "$qtstatic_dir" )"
	mv "qt-everywhere-opensource-src-${qt_ver}" "${qtstatic_dir}"
	cd "${qtstatic_dir}"
	# save some space
	rm -rf qt{webengine,webkit}
}

src_prepare() {
	local qt_patch_file_lock="${T}/.qt_patched"
	if ! [ -f "${qt_patch_file_lock}" ]; then
		# Telegram does 'slightly' patch Qt
		cd "${qtstatic_dir}/qtbase"
		local qt_patch_file="${tg_dir}/_qtbase_${qt_ver//./_}_patch.diff"
		eapply "${qt_patch_file}" && touch "${qt_patch_file_lock}"
	fi

	cd "${tg_dir}"

	local args=

	args=(
		# delete any references to local include/libs
		-e '\|/usr/local/|d'
		# delete any hardcoded includes
		-e '\|INCLUDEPATH *\+= *"/usr|d'
		# delete any hardcoded libs
		-e '\|LIBS *\+= *-l|d'
		# delete refs to bundled Google Breakpad
		-e '\|breakpad/src|d'
		# delete refs to bundled minizip, Gentoo uses it's own patched version
		-e '\|minizip|d'
		# delete CUSTOM_API_ID defines
		-e '\|CUSTOM_API_ID|d'
		# remove hardcoded flags
		-e '\|QMAKE_[A-Z]*FLAGS|d'
	)
	sed -i -r "${args[@]}" "${tg_pro}"

	# nuke libunity references
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
	sed -i -r "${args[@]}" 'SourceFiles/pspecific_linux.cpp'

	# now add corrected dependencies back
	local libs=(
		xkbcommon zlib openssl openal liblzma libavformat libavcodec libswresample libswscale
		libavutil opus libva breakpad-client minizip appindicator3-0.1
	)
	local includes=( glib-2.0 gtk+-2.0 opus breakpad-client minizip appindicator3-0.1 )
	local pkg_config="$(tc-getPKG_CONFIG)"
	(
		for p in ${libs[@]}; do
			"$pkg_config" --libs $p | awk '{print "LIBS += ",$0}'
			assert
		done
		for p in ${includes[@]}; do
			"$pkg_config" --cflags-only-I $p | sed -r 's| *-I([^ ]*) *|INCLUDEPATH += "\1"\n|g'
			assert
		done
	) >> "${tg_pro}"

	(
		# disable updater
		echo 'DEFINES += TDESKTOP_DISABLE_AUTOUPDATE'
		# disable registering `tg://` scheme from within the app
		echo 'DEFINES += TDESKTOP_DISABLE_REGISTER_CUSTOM_SCHEME'
	) >> "${tg_pro}"

	# this is surely going to be needed
	eapply_user
}

src_configure() {
	append-cxxflags '-fno-strict-aliasing' # taken from "${tg_pro}"

	cd "${qtstatic_dir}"

	local conf=(
		'-prefix' "${qt_dir}"
		'-static' '-release' '-opensource' '-confirm-license'
		'-no-strip' '-no-qml-debug'
		'-no-warnings-are-errors'
		# unneeded features
		'-no-'{opengl,cups,evdev,nis,tslib,eglfs,directfb,linuxfb,kms,gstreamer}
		'-skip' 'qtquick1'
		'-skip' 'qtdeclarative'
		# telegram doesn't support sending files >4GB
		'-no-largefile'
		# disable all SQL drivers
		'-no-sql-'{db2,ibase,mysql,oci,odbc,psql,sqlite{,2},tds}
		# use system libs
		'-system-'{zlib,pcre,harfbuzz,libpng,libjpeg,freetype,xcb}
		# disable obsolete/unused X11-related flags
		# (not shown in ./configure -help output)
		'-no-'{mitshm,x{cursor,fixes,inerama,input,randr,shape,sync,video}}
		# disable extras
		'-no-compile-examples'
		'-nomake' 'examples'
		'-nomake' 'tests'
	)
	use gtkstyle && conf+=( '-gtkstyle' ) || conf+=( '-no-gtkstyle' )

	# econf fails with `invalid command-line switch`es
	./configure "${conf[@]}"
}

src_compile() {
	cd "${qtstatic_dir}"

	if ! [ -d "$qt_dir" ]; then
		ebegin "Building Qt"
		emake module-qt{base,imageformats}
		eend
		ebegin "Installing Qt"
		emake module-qt{base,imageformats}-install_subtargets
		eend
	fi

	# prefer patched qt
	export PATH="${qt_dir}/bin:$PATH"

	local d=
	local mode=
	# `debug` must be built first, because `release` references some files from `debug` (I think)
	for mode in debug release; do
		# order of modules matters
		for module in Style Lang; do
			d="${S}/Linux/${mode^}Intermediate${module}"
			mkdir -p "${d}" && cd "${d}"

			elog "Building: ${PWD/$S\/}"
			eqmake5 CONFIG+="${mode}" "${tg_dir}/Meta${module}.pro"
			emake
		done
	done

	d="${S}/Linux/${mode^}Intermediate"
	mkdir -p "${d}" && cd "${d}"

	elog "Preparing the main build ..."
	local pre_targetdeps="$(awk '/^PRE_TARGETDEPS \+=/ { $1=$2=""; print }' "${tg_pro}")"
	# this qmake will fail to find "${tg_dir}/GeneratedFiles/*", but it's required for ...
	eqmake5 CONFIG+="${mode}" "${tg_pro}"
	# ... this make, which will generate those files
	emake $pre_targetdeps

	# now we have everything we need, so let's begin!
	elog "Building Telegram ..."
	eqmake5 CONFIG+="${mode}" "${tg_pro}"
	emake
}

src_install(){
	newbin "${S}/Linux/Release/Telegram" "${PN}"

	for icon_size in 16 32 48 64 128 256 512; do
		newicon -s ${icon_size} "${tg_dir}/SourceFiles/art/icon${icon_size}.png" "${PN}.png"
	done

	make_desktop_entry_args=(
		"\"${EROOT}usr/bin/${PN}\" -- %u"	# exec
		"${PN^}"	# name
		"${PN}"		# icon
		"Network;InstantMessaging;Chat"		# categories
	)
	make_desktop_entry_extras=(
		'Terminal=false'
		'MimeType=application/x-xdg-protocol-tg;x-scheme-handler/tg;'
	)
	make_desktop_entry "${make_desktop_entry_args[@]}" \
		"$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"

	einstalldocs
}

pkg_postinst(){
	fdo-mime_desktop_database_update
}
