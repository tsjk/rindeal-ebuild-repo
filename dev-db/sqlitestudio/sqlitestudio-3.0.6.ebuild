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

    dev-db/sqlite:3
    sqlite2? ( dev-db/sqlite:0 )

    cli? ( sys-libs/readline )
    tcl? ( dev-lang/tcl )
"
for m in $qtmodules; do
    DEPEND+="
    >=dev-qt/qt$m-$min_qt_ver"
done

RDEPEND="${DEPEND}"

S="$WORKDIR"

sqlitestudio_build_dir="$WORKDIR/output/build"
sqlitestudio_src_dir="$WORKDIR/$PN_PRETTY"
plugins_build_dir="$sqlitestudio_build_dir/Plugins"
plugins_src_dir="$WORKDIR/Plugins"

disable_modules (){
    local file="$1"
    shift
    echo "X=$#"
    if [ $# -gt 0 ]; then
        edos2unix "$file"
        for m in "$@"; do
            echo sed -i -r "/\b$m\b( \\\\|\$)/d" "$file"
            sed -i -r "/\b$m\b( \\\\|\$)/d" "$file"
        done
    fi
}

src_prepare () {
    ## Core
    disabled_modules=()

    use cli || disabled_modules+=( "cli" )

    disable_modules "$sqlitestudio_src_dir/$PN_PRETTY.pro" "${disabled_modules[@]}"

    ## Plugins
    disabled_plugins=()

    use tcl     || disabled_plugins+=( "ScriptingTcl" )
    use sqlite2 || disabled_plugins+=( "DbSqlite2" )
    use cups    || disabled_plugins+=( "Printing" )

    disable_modules "$plugins_src_dir/Plugins.pro" "${disabled_plugins[@]}"
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

    use test && qmake_args+=( "DEFINES += tests" )

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

