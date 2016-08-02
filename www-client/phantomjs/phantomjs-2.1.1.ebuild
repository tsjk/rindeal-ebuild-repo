# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )

GH_URI='github/ariya'

inherit python-any-r1 multiprocessing pax-utils qmake-utils virtualx git-hosting

DESCRIPTION='A headless WebKit scriptable with a JavaScript API'
HOMEPAGE='http://phantomjs.org'
LICENSE='BSD'

SLOT='0'

KEYWORDS='~amd64 ~arm'
IUSE='examples test'

## http://phantomjs.org/build.html - says pretty much nothing
## https://anonscm.debian.org/cgit/collab-maint/phantomjs.git/tree/debian
CDEPEND_A=( "${PYTHON_DEPS}"
	'>=dev-qt/qtcore-5.5:5'
	'>=dev-qt/qtgui-5.5:5'
	'>=dev-qt/qtnetwork-5.5:5'
	'>=dev-qt/qtprintsupport-5.5:5'
	'>=dev-qt/qtwebkit-5.5:5'
	'>=dev-qt/qtwidgets-5.5:5'

	'dev-libs/icu:='
	'dev-libs/openssl:0'
	'sys-libs/zlib'

	'media-libs/mesa'
	'media-libs/fontconfig'
	'media-libs/freetype'
	'media-libs/libpng:0='
	'virtual/jpeg:0'
)
DEPEND_A=( "${CDEPEND_A[@]}"
	# FIXME: why is this here?
	'x11-libs/libXext'
	'x11-libs/libX11'

	'test? ( dev-lang/ruby )'
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

src_prepare() {
	PATCHES=(
		"${FILESDIR}/${PN}-no-ghostdriver.patch"
		"${FILESDIR}/${PN}-qt-components.patch"
		"${FILESDIR}/${PN}-qt55-evaluateJavaScript.patch"
		"${FILESDIR}/${PN}-qt55-no-websecurity.patch"
		"${FILESDIR}/${PN}-qt55-print.patch"
	)
	default

	# c&p from qmake5()
	local qmake_args=(
		-makefile
		QMAKE_AR="$(tc-getAR) cqs"
		QMAKE_CC="$(tc-getCC)"
		QMAK_ELINK_C="$(tc-getCC)"
		QMAKE_LINK_C_SHLIB="$(tc-getCC)"
		QMAKE_CXX="$(tc-getCXX)"
		QMAKE_LINK="$(tc-getCXX)"
		QMAKE_LINK_SHLIB="$(tc-getCXX)"
		QMAKE_OBJCOPY="$(tc-getOBJCOPY)"
		QMAKE_RANLIB=
		QMAKE_STRIP=
		QMAKE_CFLAGS="${CFLAGS}"
		QMAKE_CFLAGS_RELEASE=
		QMAKE_CFLAGS_DEBUG=
		QMAKE_CXXFLAGS="${CXXFLAGS}"
		QMAKE_CXXFLAGS_RELEASE=
		QMAKE_CXXFLAGS_DEBUG=
		QMAKE_LFLAGS="${LDFLAGS}"
		QMAKE_LFLAGS_RELEASE=
		QMAKE_LFLAGS_DEBUG=
	)

	local sed_args

	sed_args=(
		-e "s|qmake = qmakePath.*|qmake = \"$(qt5_get_bindir)/qmake\"|"
		-e "s|command = \[qmake\].*|command = [qmake, $( printf '"%s",' "${qmake_args[@]}" )\"\"]|"
	)
	sed -r "${sed_args[@]}" -i -- 'build.py' || die

	sed_args=(
		# delete check for Qt version as Portage has already taken care of it
		-e '/^if\(!equals\(QT_MAJOR_VERSION/ , /}/d'
	)
	sed -r "${sed_args[@]}" -i -- 'src/phantomjs.pro' || die
}

src_compile() {
	local build_py=(
		"${PYTHON}" 'build.py'

		'--confirm'
		'--release'
		'--jobs' $(makeopts_jobs)

		'--skip-'{git,qtbase,qtwebkit}
	)

	einfo "Executing: '${build_py[*]}'"
	"${build_py[@]}" || die
}

src_test() {
	virtx "${PYTHON}" 'test/run-tests.py' || die
}

src_install() {
	pax-mark m "bin/${PN}"
	dobin "bin/${PN}"
	doman "${FILESDIR}/${PN}.1"

	einstalldocs

	if use examples ; then
		docinto examples
		dodoc -r examples
	fi
}
