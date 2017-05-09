# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

JAVA_ANT_ENCODING=UTF-8

EANT_GENTOO_CLASSPATH="
	commons-logging
	error-prone-annotations
"

# [[ ${PV} == "9999" ]] && SUBVERSION_ECLASS="subversion"
# ESVN_REPO_URI="http://josm.openstreetmap.de/svn/trunk"
inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="Java-based editor for the OpenStreetMap project"
HOMEPAGE="http://josm.openstreetmap.de/"
LICENSE="GPL-2"

SLOT="0"
# Upstream doesn't provide versioned tarballs
SRC_URI="http://http.debian.net/debian/pool/main/${PN:0:1}/${PN}/${PN}_0.0.svn${PV}+dfsg.orig.tar.gz"

KEYWORDS="~amd64"

DEPEND_A=(
	">=virtual/jdk-1.8"
	"dev-java/javacc"
	"dev-java/commons-compress"
	"dev-java/commons-logging"
	"dev-java/error-prone-annotations"
)
RDEPEND_A=(
	">=virtual/jre-1.8"
)

RESTRICT+=" mirror"

inherit arrays

S="${WORKDIR}/${PN}-0.0.svn${PV}"

# java-config-2 -p commons-logging

src_prepare() {
	default

	if [[ ${PV} == "9999" ]]; then

		# create-revision needs the compile directory to be a svn directory
		# see also http://lists.openstreetmap.org/pipermail/dev/2009-March/014182.html
		sed -i \
			-e "s:arg[ ]value=\".\":arg value=\"${ESVN_STORE_DIR}\/${PN}\/trunk\":" \
			build.xml || die "sed failed"

	else

		# Remove dependency on git and svn just for generating a
		# revision - the tarball should already have REVISION.XML
		sed -i -e 's:, *init-git-revision-xml::g' \
			-e '/<exec[ \t].*"svn"[ \t].*/,+5{d;n;}' \
			-e 's:${svn.info.result}:1:' \
			build.xml || die "sed failed"

	fi

	sed -r -e '/name="javacc.home"/ s|(location=")\$\{base.dir}/tools(")|'"\1${EROOT}usr/share/javacc/lib/\2|" \
		-i -- build.xml || die

	sed -r -e '/name="error_prone_ant.jar"/ s|(location=")\$\{base.dir}/tools/error_prone_ant-2.0.19.jar(")|'"\1${EROOT}usr/share/error-prone-annotations/lib/error-prone-annotations.jar\2|" \
		-i -- build.xml || die

	java-ant_rewrite-classpath
}

src_compile() {
	eant dist-optimized
}

src_install() {
	java-pkg_newjar "dist/${PN}-custom-optimized.jar" "${PN}.jar"
	java-pkg_dolauncher "${PN}" --jar "${PN}.jar"

	newicon images/logo.png ${PN}.png
	make_desktop_entry "${PN}" "Java OpenStreetMap Editor" ${PN} "Utility;Science;Geoscience"
}
