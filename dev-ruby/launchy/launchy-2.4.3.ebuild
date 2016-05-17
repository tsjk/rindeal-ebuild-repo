# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=5

USE_RUBY="ruby20 ruby21"

inherit ruby-fakegem

DESCRIPTION="Launchy is helper class for launching cross-platform applications in a fire a"
HOMEPAGE="http://github.com/copiousfreetime/launchy"
LICENSE="ISC"

RESTRICT="mirror test"
SLOT="0"
KEYWORDS="~amd64 ~arm"

ruby_add_rdepend '
	=dev-ruby/addressable-2*'

## ebuild generated for gem `launchy-2.4.3` by gem2ebuild on 2016-03-09
