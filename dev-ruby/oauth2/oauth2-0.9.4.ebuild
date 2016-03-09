# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

USE_RUBY="ruby20 ruby21"

inherit ruby-fakegem

DESCRIPTION="A Ruby wrapper for the OAuth 2.0 protocol built with a similar style to the o"
HOMEPAGE="http://github.com/intridea/oauth2"
LICENSE="MIT"

RESTRICT="mirror test"
SLOT="0"
KEYWORDS="~amd64 ~arm"

ruby_add_rdepend '
	<dev-ruby/faraday-0.10
	=dev-ruby/jwt-1*
	=dev-ruby/multi_json-1*
	=dev-ruby/multi_xml-0*
	=dev-ruby/rack-1*'

## ebuild generated for gem `oauth2-0.9.4` by gem2ebuild on 2016-03-09
