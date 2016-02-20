# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

USE_RUBY="ruby20 ruby21 jruby"

inherit ruby-fakegem

DESCRIPTION="CLI-based access to GitHub API v3 that works hand-in-hand with github_api gem."
HOMEPAGE="https://github.com/peter-murach/${PN}"
LICENSE="MIT"

SLOT="0"
KEYWORDS="~amd64"
