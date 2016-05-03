# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

USE_RUBY="ruby20 ruby21"

inherit ruby-fakegem

DESCRIPTION="Generates some awesome stats from git-blame"
HOMEPAGE="https://github.com/oleander/git-fame-rb"
LICENSE="MIT"

RESTRICT="mirror test"
SLOT="0"
KEYWORDS="~amd64 ~arm"

ruby_add_rdepend '
	>=dev-ruby/hirb-0
	>=dev-ruby/mimer_plus-0
	>=dev-ruby/progressbar-0
	>=dev-ruby/string-scrub-0
	>=dev-ruby/trollop-0'

## ebuild generated for gem `git_fame-1.5.0` by gem2ebuild on 2016-04-29
