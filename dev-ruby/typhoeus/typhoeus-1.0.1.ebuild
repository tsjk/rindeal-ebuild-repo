# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

USE_RUBY="ruby20 ruby21"

inherit ruby-fakegem

DESCRIPTION="Like a modern code version of the mythical beast with 100 serpent heads, Typh"
HOMEPAGE="https://github.com/typhoeus/typhoeus"
LICENSE="MIT"

RESTRICT="mirror test"
SLOT="0"
KEYWORDS="~amd64 ~arm"

ruby_add_rdepend '
	>=dev-ruby/ethon-0.8.0'

## ebuild generated for gem `typhoeus-1.0.1` by gem2ebuild on 2016-03-09
