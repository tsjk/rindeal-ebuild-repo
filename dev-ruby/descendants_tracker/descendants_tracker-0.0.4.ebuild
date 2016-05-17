# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=5

USE_RUBY="ruby20 ruby21"

inherit ruby-fakegem

DESCRIPTION="Module that adds descendant tracking to a class"
HOMEPAGE="https://github.com/dkubb/descendants_tracker"
LICENSE="MIT"

RESTRICT="mirror test"
SLOT="0"
KEYWORDS="~amd64 ~arm"

ruby_add_rdepend '
	>=dev-ruby/thread_safe-0.3.1'

## ebuild generated for gem `descendants_tracker-0.0.4` by gem2ebuild on 2016-03-09
