# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=5

USE_RUBY="ruby20 ruby21"

inherit ruby-fakegem

DESCRIPTION="An HTTP/1.1 pipelining implementation atop Net::HTTP.  A pipelined connection"
HOMEPAGE="http://docs.seattlerb.org/net-http-pipeline"
LICENSE="MIT"

RESTRICT="mirror test"
SLOT="0"
KEYWORDS="~amd64 ~arm"

## ebuild generated for gem `net-http-pipeline-1.0.1` by gem2ebuild on 2016-03-09
