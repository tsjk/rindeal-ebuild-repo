# Copyright 1999-2016 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

JAVA_PKG_IUSE="doc source"

EANT_GENTOO_CLASSPATH="
	ant
"
JAVA_GENTOO_CLASSPATH_EXTRA="/usr/share/ant/lib/ant.jar:/usr/share/guava-20/lib/guava.jar"
# ../core/src/main/java:/usr/lib64/icedtea8/lib/tools.jar:../check_api/src/main/java
# JAVA_PKG_WANT_SOURCE="1.8"
# JAVA_PKG_WANT_TARGET="1.8"

MY_PN="${PN%-ant}"
GH_RN="github:google:${MY_PN}"
GH_REF="v${PV}"

inherit java-pkg-2 java-pkg-simple
inherit git-hosting

DESCRIPTION="Java annotations for the Error Prone static analysis tool"
HOMEPAGE="http://errorprone.info ${GH_HOMEPAGE}"
LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="~amd64"

CDEPEND="dev-java/guava dev-java/ant-core"
DEPEND=">=virtual/jdk-1.8"
RDEPEND=">=virtual/jre-1.8"

inherit arrays

MY_P="${MY_PN}-${PV}"
S="${WORKDIR}/${P}"
# JAVA_SRC_DIR="src/main/java"
