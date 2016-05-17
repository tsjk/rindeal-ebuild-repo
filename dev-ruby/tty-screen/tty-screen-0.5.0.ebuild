# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=5

USE_RUBY="ruby20 ruby21"

inherit ruby-fakegem

DESCRIPTION="Terminal screen size detection which works on Linux, OS X and Windows/Cygwin "
HOMEPAGE="http://peter-murach.github.io/tty/"
LICENSE="MIT"

RESTRICT="mirror test"
SLOT="0"
KEYWORDS="~amd64 ~arm"

## ebuild generated for gem `tty-screen-0.5.0` by gem2ebuild on 2016-03-09
