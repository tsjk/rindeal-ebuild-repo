# Copyright 1999-2016 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_URI="github/getnikola"
GH_REF="v${PV}"

# nikola support python3_6, but it's deps do not
PYTHON_COMPAT=( python2_7 python3_{4,5} )

inherit distutils-r1
inherit git-hosting

DESCRIPTION="A static website and blog generator"
HOMEPAGE="https://getnikola.com/ ${GH_HOMEPAGE} https://pypi.python.org/pypi/Nikola"
LICENSE="MIT Apache-2.0 CC0-1.0 public-domain"

MY_PN="Nikola"
SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=(
	assets charts ghpages hyphenation ipython jinja markdown watchdog webmedia websocket posts-section-colors
)

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	## `setup.py`:
	">=dev-python/doit-0.28.0[${PYTHON_USEDEP}]"
	"python_targets_python2_7? ( <dev-python/doit-0.30.0[${PYTHON_USEDEP}] )"

	## `requirements.txt`:
	">=dev-python/pygments-1.6[${PYTHON_USEDEP}]"
	">=dev-python/pillow-2.4.0[${PYTHON_USEDEP}]"
	">=dev-python/python-dateutil-2.4.0[${PYTHON_USEDEP}]"
	">=dev-python/docutils-0.12[${PYTHON_USEDEP}]"
	">=dev-python/mako-1.0.0[${PYTHON_USEDEP}]"
	">=dev-python/unidecode-0.04.16[${PYTHON_USEDEP}]"
	">=dev-python/lxml-3.3.5[${PYTHON_USEDEP}]"
	">=dev-python/yapsy-1.11.223[${PYTHON_USEDEP}]"
	">=dev-python/PyRSS2Gen-1.1[${PYTHON_USEDEP}]"
	">=dev-python/logbook-0.7.0[${PYTHON_USEDEP}]"
	">=dev-python/blinker-1.3[${PYTHON_USEDEP}]"
	">=dev-python/setuptools-20.3[${PYTHON_USEDEP}]"
	">=dev-python/natsort-3.5.2[${PYTHON_USEDEP}]"
	">=dev-python/requests-2.2.0[${PYTHON_USEDEP}]"
	">=dev-python/piexif-1.0.3[${PYTHON_USEDEP}]"

	## `requirements-extras.txt`:
	"markdown?	( >=dev-python/markdown-2.4.0[${PYTHON_USEDEP}] )"
	"jinja?		( >=dev-python/jinja-2.7.2[${PYTHON_USEDEP}] )"
	"posts-section-colors? ( >=dev-python/husl-4.0.2[${PYTHON_USEDEP}] )"
	"hyphenation?	( >=dev-python/pyphen-0.9.1[${PYTHON_USEDEP}] )"
	"webmedia?	( >=dev-python/micawber-0.3.0[${PYTHON_USEDEP}] )"
	"charts?	( >=dev-python/pygal-2.0.0[${PYTHON_USEDEP}] )"
	# not in gentoo repos; needs smartypants; old (2014) and umaintained
	# "typography? ( >=dev-python/typogrify-2.0.4[${PYTHON_USEDEP}] )"
	# not in gentoo repos; old (2012) and umaintained
	# "wordpress-import? ( >=dev-python/phpserialize-1.3[${PYTHON_USEDEP}] )"
	"assets? ( >=dev-python/webassets-0.10.1[${PYTHON_USEDEP}] )"
	"ghpages? ( >=dev-python/ghp-import-0.4.1[${PYTHON_USEDEP}] )"
	"websocket? ( ~dev-python/ws4py-0.3.5[${PYTHON_USEDEP}] )"
	"watchdog? ( ~dev-python/watchdog-0.8.3[${PYTHON_USEDEP}] )"
	"ipython? ("
		">=dev-python/ipython-2.0.0[notebook,${PYTHON_USEDEP}]"
		">=dev-python/notebook-4.0.0[${PYTHON_USEDEP}]"
		">=dev-python/ipykernel-4.0.0[${PYTHON_USEDEP}]"
	")"

# 	"test? ("
		## `requirements-tests.txt`:
# 		"~dev-python/mock-2.0.0[${PYTHON_USEDEP}]"
# 		"~dev-python/coverage-4.3.4[${PYTHON_USEDEP}]" # FIXME: gentoo repo contains old version
# 		"~dev-python/pytest-3.0.6[${PYTHON_USEDEP}]"
# 		"~dev-python/pytest-cov-2.4.0[${PYTHON_USEDEP}]" # FIXME: gentoo repo contains old version
# 		"~dev-python/freezegun-0.3.8[${PYTHON_USEDEP}]"
# 		"~dev-python/codacy-coverage-1.3.6[${PYTHON_USEDEP}]" # FIXME: not in gentoo repos
# 		">=dev-python/colorama-0.3.4[${PYTHON_USEDEP}]"
# 	")"
)

RESTRICT="test" # needs coveralls

inherit arrays

src_prepare() {
	eapply_user

	# bloat
	RM_V=0 erm -r snapcraft

	# fix docdir
	sed -e "s@'share/doc/nikola', \[@'share/doc/${PF}', \[@" -i -- setup.py || die

	distutils-r1_src_prepare
}

src_install() {
	distutils-r1_src_install

	dodoc AUTHORS.txt CHANGES.txt README.rst docs/*.txt
	doman docs/man/${PN}.1.gz
}
