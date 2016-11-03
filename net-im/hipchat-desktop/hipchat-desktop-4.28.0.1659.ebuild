# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

inherit unpacker
inherit versionator
inherit xdg

DESCRIPTION="HipChat desktop client for Linux"
HOMEPAGE="https://www.hipchat.com/downloads#linux"
LICENSE="atlassian"

SLOT="0"
SRC_URI="https://atlassian.artifactoryonline.com/atlassian/hipchat-apt-client/pool/HipChat$(get_major_version)-${PV}-Linux.deb"

KEYWORDS="~amd64"

CDEPEND=""
DEPEND="${CDEPEND}"
RDEPEND="${CDEPEND}"

RESTRICT+=" mirror"

S="${WORKDIR}"

src_install() {
	insinto /opt/
	doins -r opt/HipChat$(get_major_version)

	domenu "usr/share/applications/hipchat$(get_major_version).desktop"

	insinto /usr/share/icons/
	doins -r usr/share/icons/hicolor

	fperms a+x /opt/HipChat$(get_major_version)/bin/{HipChat$(get_major_version),QtWebEngineProcess,hellocpp}
	fperms a+x /opt/HipChat$(get_major_version)/lib/{linuxbrowserlaunch.sh,HipChat.bin,QtWebEngineProcess.bin}
}

QA_PREBUILT="opt/HipChat4/*"
