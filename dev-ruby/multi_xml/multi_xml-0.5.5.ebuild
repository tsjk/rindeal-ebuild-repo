# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=5

USE_RUBY="ruby20 ruby21"

inherit ruby-fakegem

DESCRIPTION="Provides swappable XML backends utilizing LibXML, Nokogiri, Ox, or REXML."
HOMEPAGE="https://github.com/sferik/multi_xml"
LICENSE="MIT"

RESTRICT="mirror test"
SLOT="0"
KEYWORDS="~amd64 ~arm"

## ebuild generated for gem `multi_xml-0.5.5` by gem2ebuild on 2016-03-09
