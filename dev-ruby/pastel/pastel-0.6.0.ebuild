# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=5

USE_RUBY="ruby20 ruby21"

inherit ruby-fakegem

DESCRIPTION="Terminal strings styling with intuitive and clean API."
HOMEPAGE="https://github.com/peter-murach/pastel"
LICENSE="MIT"

RESTRICT="mirror test"
SLOT="0"
KEYWORDS="~amd64 ~arm"

ruby_add_rdepend '
	=dev-ruby/equatable-0.5*
	=dev-ruby/tty-color-0.3*'

## ebuild generated for gem `pastel-0.6.0` by gem2ebuild on 2016-03-09
