# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

USE_RUBY="ruby20 ruby21"

inherit ruby-fakegem

DESCRIPTION="WebMock allows stubbing HTTP requests and setting expectations on HTTP requests."
HOMEPAGE="http://github.com/bblimke/webmock"
LICENSE="MIT"

RESTRICT="mirror test"
SLOT="0"
KEYWORDS="~amd64 ~arm"

ruby_add_rdepend '
	>=dev-ruby/addressable-2.3.6
	>=dev-ruby/crack-0.3.2
	>=dev-ruby/hashdiff-0'

## ebuild generated for gem `webmock-1.24.2` by gem2ebuild on 2016-03-09
