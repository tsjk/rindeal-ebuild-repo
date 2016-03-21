# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_DEPEND="python? 2"
LANGS="de fr ja ru uk zh_TW"
PYTHON_COMPAT=( "python2_7" )

inherit eutils python-r1 qmake-utils qt4-r2

DESCRIPTION="Cross platform GUI for several code formatters, beautifiers and indenters"
HOMEPAGE="http://universalindent.sourceforge.net/"
LICENSE="GPL-2"
SRC_URI="mirror://sourceforge/universalindent/${P}.tar.gz"

SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE="
	debug examples

	html perl php python ruby uncrustify xml
"

DEPEND="
	dev-qt/qtcore:4
	dev-qt/qtgui:4
	dev-qt/qtscript:4
	x11-libs/qscintilla
"
RDEPEND+="
	dev-util/astyle
	dev-util/indent
	html? (
		app-text/htmltidy
		perl? ( dev-lang/perl )
	)
	perl? ( dev-perl/Perl-Tidy )
	php? ( dev-php/PEAR-PHP_Beautifier )
	ruby? ( dev-lang/ruby )
	xml? ( dev-util/xmlindent )
	uncrustify? ( dev-util/uncrustify )
"

DOCS="CHANGELOG.txt readme.html"

pkg_setup() {
	if use python; then
		python_set_active_version 2
		python_pkg_setup
	fi
}

src_prepare() {
	# correct translation binaries
	sed -e "s|lupdate-qt4|$(qt4_get_bindir)/lupdate|" \
		-e "s|lrelease-qt4|$(qt4_get_bindir)/lrelease|" \
		-i UniversalIndentGUI.pro || die "sed pro translation binary"

	if use debug; then
		sed -i -e 's|release,|debug,|g' UniversalIndentGUI.pro || die
	fi

	# patch .pro file according to our use flags
	# basic support
	UEXAMPLES="cpp sh"
	local UINDENTERS="shellindent.awk"
	local UIGUIFILES="shellindent gnuindent astyle"

	if use html; then
		UEXAMPLES+=" html"
		UIGUIFILES+=" tidy"
		if use perl; then
			UINDENTERS+=" hindent"
			UIGUIFILES+=" hindent"
		fi
	fi

	if use perl; then
		UEXAMPLES+=" pl"
		UIGUIFILES+=" perltidy"
	fi

	if use php; then
		UEXAMPLES+=" php"
		UINDENTERS+=" phpStylist.php"
		UIGUIFILES+=" php_Beautifier phpStylist"
	fi

	if use python; then
		UEXAMPLES+=" py"
		UINDENTERS+=" pindent.py"
		UIGUIFILES+=" pindent"
		python_convert_shebangs -r 2 .
	fi

	if use ruby; then
		UEXAMPLES+=" rb"
		UINDENTERS+=" rbeautify.rb ruby_formatter.rb"
		UIGUIFILES+=" rbeautify rubyformatter"
	fi

	if use xml; then
		UEXAMPLES+=" xml"
		UIGUIFILES+=" xmlindent"
	fi

	if use uncrustify; then
		UIGUIFILES+=" uncrustify"
	fi

	local IFILES= I=
	for I in ${UINDENTERS}; do
		IFILES+=" indenters/${I}"
		chmod +x indenters/${I}
	done

	for I in ${UIGUIFILES}; do
		IFILES+=" indenters/uigui_${I}.ini"
	done

	# apply fixes in .pro file
	sed -i -e "/^unix:indenters.files +=/d" UniversalIndentGUI.pro ||
		die ".pro patching failed"
	sed -i -e "s:indenters/uigui_\*\.ini:${IFILES}:" UniversalIndentGUI.pro ||
		die ".pro patching failed"

	local lang
	for lang in ${LANGS}; do
		if ! use linguas_${lang}; then
			sed -e "/_${lang}.ts/d" -e "/_${lang}.qm/d" \
				-i UniversalIndentGUI.pro || die "failed while disabling ${lang}"
		fi
	done

	qt4-r2_src_prepare
}

src_install() {
	qt4-r2_src_install

	doman doc/${PN}.1.gz

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		local I
		for I in ${UEXAMPLES}; do
			doins indenters/example.${I}
		done
	fi

	newicon -s 512 resources/universalIndentGUI_512x512.png ${PN}

	make_desktop_entry_args=(
		"${PN}"	 				# exec
		"UniversalIndentGUI"	# name
		"${PN}"					# icon
		"Development;Utility"	# categories
	)
	make_desktop_entry_extras=(
		'Terminal=false'
		# TODO: "MimeType=;"
	)
	make_desktop_entry \
		"${make_desktop_entry_args[@]}" \
		"$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"
}
