# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=5

USE_RUBY="ruby20 ruby21"

inherit ruby-fakegem

DESCRIPTION="Terminal output paging in a cross-platform way supporting all major ruby inte"
HOMEPAGE="https://github.com/peter-murach/tty-pager"
LICENSE="MIT"

RESTRICT="mirror test"
SLOT="0"
KEYWORDS="~amd64 ~arm"

ruby_add_rdepend '
	=dev-ruby/tty-screen-0.5*
	=dev-ruby/tty-which-0.1*
	=dev-ruby/verse-0.4*'

## ebuild generated for gem `tty-pager-0.4.0` by gem2ebuild on 2016-03-09
