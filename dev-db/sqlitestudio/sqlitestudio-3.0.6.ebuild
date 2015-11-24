# Copyright (C) 2015; Jan Chren <dev.rindeal@outlook.com>
# Distributed under the terms of the GNU General Public License v2
# $Id$

# http://wiki.sqlitestudio.pl/index.php/Compiling_application_from_sources

EAPI=5

PN_PRETTY="SQLiteStudio3"

DESCRIPTION="$PN_PRETTY is a powerful cross-platform SQLite database manager"
HOMEPAGE="http://sqlitestudio.pl"
LICENSE="GPL-3"
SRC_URI="$HOMEPAGE/files/sqlitestudio3/complete/tar/$P.tar.gz"

inherit qmake-utils fdo-mime

SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="
    sqlite2
    cli
    tcl
    cups
    test
"

min_qt_ver=5.3
qtmodules="core gui widgets script network xml svg"
use test && qtmodules+=" test"

DEPEND="
    >=sys-devel/gcc-4.8

    >=dev-qt/designer-$min_qt_ver
    cups? ( >=dev-qt/qtprintsupport-$min_qt_ver )
    $(
        for m in $qtmodules; do
            echo ">=dev-qt/qt$m-$min_qt_ver"
        done
    )

    dev-db/sqlite:3
    sqlite2? ( dev-db/sqlite:0 )

    cli? ( sys-libs/readline )
    tcl? ( dev-lang/tcl )
"

RDEPEND="${DEPEND}"

S="$WORKDIR"

sqlitestudio_build_dir="$WORKDIR/output/build"
sqlitestudio_src_dir="$WORKDIR/$PN_PRETTY"
plugins_build_dir="$sqlitestudio_build_dir/Plugins"
plugins_src_dir="$WORKDIR/Plugins"

src_prepare () {
    local file

    ## Core
    if ! use cli; then
        file="$sqlitestudio_src_dir/$PN_PRETTY.pro"
        edos2unix "$file"
        sed -i -r '/\bcli\b( \\|$)/d' "$file"
    fi

    ## Plugins
    local disabled_plugins=(
        "$( use tcl      || echo "ScriptingTcl" )"
        "$( use sqlite2  || echo "DbSqlite2" )"
        "$( use cups     || echo "Printing" )"
    )

    if [ ${#disabled_plugins[@]} -gt 0 ]; then
        file="$plugins_src_dir/Plugins.pro"
        edos2unix "$file"
        for p in "${disabled_plugins[@]}"; do
            sed -i -r "/\b$p\b( \\\\|\$)/d" "$file"
        done
    fi

}

src_compile () {
    ## Core

    mkdir -p "$sqlitestudio_build_dir" && cd "$sqlitestudio_build_dir"

    local qmake_args=(
        "LIBDIR=$EPREFIX/usr/$(get_libdir)"
        "BINDIR=$EPREFIX/usr/bin"

        "DEFINES += PLUGINS_DIR=$EPREFIX/usr/$(get_libdir)/$PN"
        "DEFINES += ICONS_DIR=$EPREFIX/usr/share/$PN/icons"
        "DEFINES += FORMS_DIR=$EPREFIX/usr/share/$PN/forms"

        # not strictly needed since version 3.0.6, but nevermind
        "DEFINES += NO_AUTO_UPDATES"
    )

    use test && qmake_args+="DEFINES += tests"

    eqmake5 "${qmake_args[@]}" "$sqlitestudio_src_dir"
    emake

    ## Plugins

    mkdir -p "$plugins_build_dir" && cd "$plugins_build_dir"

    eqmake5 "${qmake_args[@]}" "$plugins_src_dir"
    emake
}

src_install () {
    cd "$sqlitestudio_build_dir"
    emake INSTALL_ROOT="$D" install

    cd "$plugins_build_dir"
    emake INSTALL_ROOT="$D" install

    dodoc "$sqlitestudio_src_dir/docs/sqlitestudio3_docs.cfg"
    doicon "${FILESDIR}/$PN.svg"
    make_desktop_entry \
        "$EPREFIX/usr/bin/$PN %F" \
        "$PN_PRETTY" \
        "$PN.svg" \
        "Development;Utility" \
        "$(
            echo 'Terminal=false'
            echo "MimeType=application/x-sqlite3;$(use sqlite2 && echo 'application/x-sqlite2;')"
         )"
}

pkg_postinst() {
    fdo-mime_desktop_database_update
}

