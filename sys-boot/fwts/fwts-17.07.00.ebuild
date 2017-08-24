# Copyright 1999-2015 Gentoo Foundation
# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# functions: eutoreconf
inherit autotools
# functions: tc-getNM
inherit toolchain-funcs
# functions: prune_libtool_files
inherit eutils

DESCRIPTION="Firmware Test Suite (ACPI, BIOS, UEFI, ...)"
HOMEPAGE="https://wiki.ubuntu.com/Kernel/Reference/fwts"
LICENSE="GPL-2"

SLOT="0"
# get newest release:
# 
#     wget -q -O - "http://archive.ubuntu.com/ubuntu/pool/universe/f/fwts/?C=M;O=D" | grep orig.tar | head -n 1 | grep -P -o '(?<=">)[^<>]+(?=</a)'
#
SRC_URI="https://launchpad.net/ubuntu/+archive/primary/+files/${PN}_${PV}.orig.tar.gz"

KEYWORDS="~amd64"
IUSE=""

CDEPEND_A=(
	">=dev-libs/json-c-0.10-r1"
	"dev-libs/glib:2"
	"dev-libs/libpcre"
	"sys-apps/pciutils"
	"sys-power/iasl"
	"sys-power/pmtools"
	"sys-apps/dmidecode"
)
DEPEND_A=(
	"${CDEPEND_A[@]}"
	"sys-devel/libtool"
	"sys-devel/flex"
	"sys-devel/bison"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	# `gentoo` repo pkg name
	"!sys-apps/fwts"
)

S="${WORKDIR}"

src_prepare(){
	default

	grep -r --files-with-matches ' -Werror' | xargs \
		sed -e 's| -Werror||' \
			-i --
	assert
	sed -e 's:/usr/bin/lspci:'$(type -p lspci)':' \
		-i -- src/lib/include/fwts_binpaths.h || die

	# Fix json-c includes
	sed -e 's|^#include <json/|#include <json-c/|g' \
		-i -- configure.ac || die
	sed -e 's|^#include <json.h>|#include <json-c/json.h>|' \
		-i -- src/lib/include/fwts_json.h \
			src/utilities/kernelscan.c || die

	eautoreconf

	# Sandbox fails due to https://bugs.gentoo.org/show_bug.cgi?id=598810,
	# because bash executes the globs inside $_G_message.
	# Specific content that fails is: https://pastebin.com/B4kgCYpJ.
	sed -e 's|for _G_line in $_G_message; do|for _G_line in "$_G_message"; do|' -i -- ltmain.sh || die
}

src_configure() {
	econf --disable-static
}

src_install() {
	default

	prune_libtool_files
}
