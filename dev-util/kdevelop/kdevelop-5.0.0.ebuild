# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

KDE_HANDBOOK="forceoptional"
KDE_TEST="forceoptional-recursive"

VIRTUALX_REQUIRED="test"

inherit kde5

DESCRIPTION="Integrated Development Environment, supporting KF5/Qt, C/C++ and much more"
LICENSE="GPL-2 LGPL-2"

IUSE="+cxx +cmake +gdbui ninja okteta plasma qmake qthelp"
KEYWORDS="~amd64"

CDEPEND_A=(
	## ${S}/CMakeLists.txt:
	## 	- ordering follows upstream
	"$(add_qt_dep qtwidgets)"
	# "$(add_qt_dep qtconcurrent)" # build only dep
	"$(add_qt_dep qtdeclarative)" # Quick, QuickWidgets
	"$(add_qt_dep qtwebkit)" # WebKitWidgets

	"$(add_frameworks_dep kconfig)"
	"$(add_frameworks_dep kdeclarative)"
	"$(add_frameworks_dep kdoctools)"
	"$(add_frameworks_dep kiconthemes)"
	"$(add_frameworks_dep ki18n)"
	"$(add_frameworks_dep kitemmodels)"
	"$(add_frameworks_dep kitemviews)"
	"$(add_frameworks_dep kjobwidgets)"
	"$(add_frameworks_dep kcmutils)"
	"$(add_frameworks_dep kio)"
	"$(add_frameworks_dep knewstuff)"
	"$(add_frameworks_dep knotifyconfig)"
	"$(add_frameworks_dep kparts)"
	"$(add_frameworks_dep kservice)"
	"$(add_frameworks_dep ktexteditor)"
	"$(add_frameworks_dep threadweaver)"
	"$(add_frameworks_dep kxmlgui)"
	"$(add_frameworks_dep kwindowsystem)"
	"$(add_frameworks_dep kcrash)"

	# automagic dep
	"$(add_qt_dep qtdbus)"

	# 'languages/qmljs/libs/CMakeLists.txt'
	"$(add_qt_dep qtgui)"
	"$(add_qt_dep qtnetwork)"
	"$(add_qt_dep qtxml)"

	">=dev-util/kdevplatform-${PV}:5"
	"x11-misc/shared-mime-info"

	"cmake? ("
		"$(add_frameworks_dep kcompletion)"
	")"
	"cxx? ( >=sys-devel/clang-3.5.0 )"
	"gdbui? ( $(add_plasma_dep libksysguard) )"
	"okteta? ("
		"$(add_kdeapps_dep okteta)"
		"$(add_frameworks_dep kwidgetsaddons)"
	")"
	"plasma? ("
		"$(add_frameworks_dep krunner)"
		"$(add_frameworks_dep plasma)"
	")"
	"qmake? ("
		"dev-util/kdevelop-pg-qt:5"
		"$(add_frameworks_dep kcoreaddons)"
	")"
	"qthelp? ( $(add_qt_dep qthelp) )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"$(add_qt_dep qtconcurrent)"
)
RDEPEND_A=( "${CDEPEND_A}"
	"$(add_kdeapps_dep kapptemplate)"
	"$(add_kdeapps_dep kio-extras)"
	">=sys-devel/gdb-7.0[python]"

	"ninja? ( dev-util/ninja )"

	## file collisions
	"!dev-util/kdevelop:4"
	"!dev-util/kdevelop-clang"
	"!dev-util/kdevelop-qmake"
	"!dev-util/kdevelop-qmljs"
	"!<kde-apps/kapptemplate-16.04.0"
)

RESTRICT+=" test"
# see bug 366471

PATCHES=(
	"${FILESDIR}/5.0.0-ninja-optional.patch"
	"${FILESDIR}/5.0.0-fix-cpp.patch"
)

src_configure() {
	local mycmakeargs=(
		# TODO: why?
		-DBUILD_cpp=OFF

		-D BUILD_cmake=$(usex cmake)
		-D BUILD_cmakebuilder=$(usex cmake)
		-D LEGACY_CPP_SUPPORT=$(usex !cxx)
		$(cmake-utils_use_find_package gdbui KF5SysGuard)
		-D BUILD_executeplasmoid=$(usex plasma)
		$(cmake-utils_use_find_package plasma KF5Plasma)
		-D BUILD_ninjabuilder=$(usex ninja)
		$(cmake-utils_use_find_package okteta OktetaKastenControllers)
		$(cmake-utils_use_find_package qmake KDevelop-PG-Qt)
		-D BUILD_qthelp=$(usex qthelp)
	)

	kde5_src_configure
}
