# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

USE_RUBY="ruby20 ruby21 jruby"

inherit ruby-fakegem

DESCRIPTION="Travis CI Client (CLI and Ruby library)"
HOMEPAGE="https://github.com/travis-ci/travis.rb"
LICENSE="MIT"

RESTRICT="mirror"
SLOT="0"
KEYWORDS="~amd64"
