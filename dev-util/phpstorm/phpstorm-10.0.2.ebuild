# Copyright (C) 2015; Jan Chren <dev.rindeal@outlook.com>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils fdo-mime

PN_PRETTY="PhpStorm"
DESCRIPTION="PhpStorm is a commercial, cross-platform IDE for PHP built on JetBrains' IntelliJ IDEA platform."
HOMEPAGE="https://www.jetbrains.com/${PN}/"
SRC_URI="https://download.jetbrains.com/webide/${PN_PRETTY}-${PV}.tar.gz"
LICENSE="
    PhpStorm_personal_license
    PhpStorm_OpenSource_license
    PhpStorm_Academic_license
    PhpStorm_Classroom_license
    PhpStorm_license
"

SLOT="10"
KEYWORDS="~amd64 ~x86 ~arm"
RESTRICT="strip mirror"

RDEPEND="|| ( >=virtual/jdk-1.7 >=virtual/jre-1.6 ) "

S="$WORKDIR"

# TODO: as soon as unpacker.eclass implements partial unpacks,
# we should exclude "<ROOT_DIR>/jre" dir here
# src_unpack() { }

src_prepare() {
    pn_pretty_uniq="${PN_PRETTY}${SLOT}"
    bin_name="${PN}${SLOT}"

    cd ${PN_PRETTY}-*/
    S="$PWD"

    sed -i 's/IS_EAP="true"/IS_EAP="false"/' bin/${PN}.sh

    # use system JDK
    rm -rf jre/

    mv "bin/webide.png" "bin/${bin_name}.png"
}

src_install() {
    local install_dir="/opt/${pn_pretty_uniq}"

    insinto "$install_dir"
    doins -r .

    fperms a+x "$install_dir/bin/"{${PN}.sh,fsnotifier{,64,-arm}}
    dosym "$install_dir/bin/${PN}.sh" /usr/bin/${bin_name}

    doicon -s 256 "bin/${bin_name}.png"

    make_desktop_entry_args=(
        "${bin_name} %U"                        # exec
        "$pn_pretty_uniq"                       # name
        "${bin_name}"                           # icon
        "Development"                           # categories
    )
    make_desktop_entry_extras=(
        "MimeType=text/x-php;text/html;"        # MUST end with semicolon
    )

    make_desktop_entry "${make_desktop_entry_args[@]}" "$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"
}

pkg_postinst() {
    fdo-mime_desktop_database_update
}
