# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=5

USE_RUBY="ruby20 ruby21"

inherit ruby-fakegem

DESCRIPTION="A beautiful and powerful interactive command line prompt with a robust API fo"
HOMEPAGE="http://peter-murach.github.io/tty"
LICENSE="MIT"

RESTRICT="mirror test"
SLOT="0"
KEYWORDS="~amd64 ~arm"

ruby_add_rdepend '
	=dev-ruby/necromancer-0.3*
	=dev-ruby/pastel-0.6*
	=dev-ruby/tty-cursor-0.2*
	=dev-ruby/tty-platform-0.1*
	=dev-ruby/wisper-1.6*'

## ebuild generated for gem `tty-prompt-0.4.0` by gem2ebuild on 2016-03-09
