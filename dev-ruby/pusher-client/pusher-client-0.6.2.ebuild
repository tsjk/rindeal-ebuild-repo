# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

USE_RUBY="ruby20 ruby21"

inherit ruby-fakegem

DESCRIPTION="Client for consuming WebSockets from http://pusher.com"
HOMEPAGE="http://github.com/pusher/pusher-ruby-client"
LICENSE="MIT"

RESTRICT="mirror test"
SLOT="0"
KEYWORDS="~amd64 ~arm"

ruby_add_rdepend '
	>=dev-ruby/json-0
	=dev-ruby/websocket-1*'

## ebuild generated for gem `pusher-client-0.6.2` by gem2ebuild on 2016-03-09
