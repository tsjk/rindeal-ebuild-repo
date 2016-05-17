# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=5

USE_RUBY="ruby20 ruby21 jruby"

inherit ruby-fakegem

DESCRIPTION="Travis CI Client (CLI and Ruby library)"
HOMEPAGE="https://github.com/travis-ci/travis.rb"
LICENSE="MIT"

RESTRICT="mirror"
SLOT="0"
KEYWORDS="~amd64 ~arm"

RUBY_FAKEGEM_EXTRAINSTALL="assets"
