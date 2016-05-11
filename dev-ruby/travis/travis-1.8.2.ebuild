# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

USE_RUBY="ruby20 ruby21"

inherit ruby-fakegem

DESCRIPTION="CLI and Ruby client library for Travis CI"
HOMEPAGE="https://github.com/travis-ci/travis.rb"
LICENSE="MIT"

RESTRICT="mirror test"
SLOT="0"
KEYWORDS="~amd64 ~arm"

ruby_add_rdepend '
	>=dev-ruby/backports-0
	=dev-ruby/faraday-0*
	>=dev-ruby/faraday_middleware-0.9.1
	=dev-ruby/gh-0*
	=dev-ruby/highline-1*
	=dev-ruby/launchy-2*
	=dev-ruby/pusher-client-0*
	>=dev-ruby/typhoeus-0.6.8'

RUBY_FAKEGEM_EXTRAINSTALL="assets"

## ebuild generated for gem `travis-1.8.2` by gem2ebuild on 2016-03-09
