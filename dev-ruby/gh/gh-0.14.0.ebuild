# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

USE_RUBY="ruby20 ruby21"

inherit ruby-fakegem

DESCRIPTION="multi-layer client for the github api v3"
HOMEPAGE="http://gh.rkh.im/"
LICENSE="MIT"

RESTRICT="mirror test"
SLOT="0"
KEYWORDS="~amd64 ~arm"

ruby_add_rdepend '
	>=dev-ruby/addressable-0
	>=dev-ruby/backports-0
	=dev-ruby/faraday-0*
	=dev-ruby/multi_json-1*
	>=dev-ruby/net-http-persistent-2.7
	>=dev-ruby/net-http-pipeline-0'

## ebuild generated for gem `gh-0.14.0` by gem2ebuild on 2016-03-09
