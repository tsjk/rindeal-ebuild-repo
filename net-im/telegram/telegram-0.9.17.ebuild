# Copyright (C) 2015; Jan Chren <dev.rindeal@outlook.com>
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils fdo-mime versionator

DESCRIPTION="Desktop client of Telegram, the messaging app."
HOMEPAGE="https://telegram.org"
LICENSE="GPL-3"

_qtver=5.5.1
_qtver_short=$( get_version_component_range 1-2 $_qtver )

SRC_URI="(
    https://github.com/telegramdesktop/tdesktop/archive/v${PV}.tar.gz -> ${P}.tar.gz
    http://download.qt-project.org/official_releases/qt/${_qtver_short}/$_qtver/single/qt-everywhere-opensource-src-${_qtver}.tar.xz
)"

SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror"

IUSE="gtkstyle"

RDEPEND="
    dev-libs/icu
    virtual/ffmpeg
    media-libs/jasper
    media-libs/libexif
    media-libs/libmng
    media-libs/libwebp
    x11-libs/libxkbcommon
    x11-libs/gtk+:2
    sys-libs/mtdev
    =media-libs/openal-9999
    media-libs/opus
    dev-libs/glib:2
    dev-libs/libappindicator:3
"
DEPEND="
    ${RDEPEND}
    dev-libs/libunity
    x11-base/xorg-server[xvfb]
"

S="${WORKDIR}/tdesktop-${PV}"
telegram_dir="${S}/Telegram"

QSTATIC="${WORKDIR}/Libraries/QtStatic"
_QTDIR="${WORKDIR}/qt"

src_prepare(){
    mkdir -p "$( dirname "$QSTATIC" )"
    mv "qt-everywhere-opensource-src-${_qtver}" "${QSTATIC}"

    cd "${QSTATIC}/qtbase"
    # Telegram does 'slightly' patches Qt
    epatch "${telegram_dir}/_qtbase_${_qtver//./_}_patch.diff"

    cd "${telegram_dir}"

    # Switch to libappindicator3 (dev-libs/libappindicator::gentoo-zh)
    sed -i 's/libappindicator/libappindicator3/g' Telegram.pro

    # Telegram, hey, tell me what the hell is this?
    sed -i 's/\/usr\/local\/lib\/libxkbcommon.a/-lxkbcommon/g' Telegram.pro

    # We don't have a custom id
    sed -i 's/CUSTOM_API_ID//g' Telegram.pro

    # Upstream likes broken things
    (
        echo 'DEFINES += TDESKTOP_DISABLE_AUTOUPDATE'
        echo 'DEFINES += TDESKTOP_DISABLE_REGISTER_CUSTOM_SCHEME'
    ) >> Telegram.pro

    (
        echo 'INCLUDEPATH += "/usr/lib/glib-2.0/include"'
        echo 'INCLUDEPATH += "/usr/lib/gtk-2.0/include"'
        echo 'INCLUDEPATH += "/usr/include/opus"'
    ) >> Telegram.pro
}

src_configure(){
    cd "${QSTATIC}"

    local conf=(
        -prefix "${_QTDIR}"

        -static

        -release
        -opensource -confirm-license

        -qt-xcb
        -no-opengl

        -skip qtquick1
        -skip qtdeclarative

        # telegram doesn't support sending files >4GB
        -no-largefile
        -no-qml-debug

        # disable all SQL drivers by default, override in qtsql
        -no-sql-db2 -no-sql-ibase -no-sql-mysql -no-sql-oci -no-sql-odbc
        -no-sql-psql -no-sql-sqlite -no-sql-sqlite2 -no-sql-tds

        -system-zlib -system-pcre

        # always enable glib event loop support
        -glib

        # always enable iconv support
        -iconv

        # disable obsolete/unused X11-related flags
        # (not shown in ./configure -help output)
        -no-mitshm -no-xcursor -no-xfixes -no-xinerama -no-xinput
        -no-xrandr -no-xshape -no-xsync -no-xvideo

        # always enable session management support: it doesn't need extra deps
        # at configure time and turning it off is dangerous, see bug 518262
        -sm

        -nomake examples
        -no-compile-examples
        -nomake tests

        # do not build with -Werror
        -no-warnings-are-errors
    )
    use gtkstyle && conf+=( '-gtkstyle' )

    # econf fails with `invalid command-line switch`es
    ./configure "${conf[@]}"
}

src_compile(){
    cd "${QSTATIC}"

    emake module-qtbase module-qtimageformats
    emake module-qtbase-install_subtargets module-qtimageformats-install_subtargets

    # ??
    export PATH="${FILESDIR}:${_QTDIR}/bin:$PATH"

    mkdir -p "${S}/Linux/"{Debug,Release}Intermediate{Style,Emoji,Lang,Updater}

    # Begin the hacky build
    # Adapted from AUR package
    # It needs a fake Xorg server, in ${FILESDIR}
    for _type in debug release; do
        for x in Style Lang; do
            cd "${S}/Linux/${_type^}Intermediate${x}"
            echo qmake CONFIG+="${_type}" "${telegram_dir}/Meta${x}.pro"
            qmake CONFIG+="${_type}" "${telegram_dir}/Meta${x}.pro"
            make || die 'Make failed'
        done

        cd "${S}/Linux/${_type^}Intermediate"

        if ! [ -d "${telegram_dir}/GeneratedFiles" ]; then
            qmake CONFIG+="${_type}" "${telegram_dir}/Telegram.pro"
            awk '$1 == "PRE_TARGETDEPS" { $1=$2="" ; print }' "${telegram_dir}/Telegram.pro" | \
                xargs xvfb-run -a make || die 'Make failed'
        fi

        qmake CONFIG+=${_type} "${telegram_dir}/Telegram.pro"
        xvfb-run -a make || die 'Make failed'
    done
}

src_install(){
    newbin "${S}/Linux/Release/Telegram" telegram

    # From AOSC
    insopts -m644
    for icon_size in 16 32 48 64 128 256 512; do
        newicon -s ${icon_size} "${telegram_dir}/SourceFiles/art/icon${icon_size}.png" telegram.png
    done

    domenu "${FILESDIR}/telegram.desktop"
}

pkg_postinst(){
    fdo-mime_desktop_database_update
}
