# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=5

USE_RUBY="ruby20 ruby21"

inherit ruby-fakegem

DESCRIPTION="HashDiff is a diff lib to compute the smallest difference between two hashes."
HOMEPAGE="https://github.com/liufengyun/hashdiff"
LICENSE="MIT"

RESTRICT="mirror test"
SLOT="0"
KEYWORDS="~amd64 ~arm"

## ebuild generated for gem `hashdiff-0.3.0` by gem2ebuild on 2016-03-09
