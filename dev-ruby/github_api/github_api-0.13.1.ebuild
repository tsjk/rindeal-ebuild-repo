# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

USE_RUBY="ruby20 ruby21"

RUBY_FAKEGEM_RECIPE_TEST="rspec"
RUBY_FAKEGEM_RECIPE_DOC="rdoc"
RUBY_FAKEGEM_EXTRADOC="README.md"
inherit ruby-fakegem

DESCRIPTION="Ruby client that supports all of the GitHub API methods. It's build in a modu"
HOMEPAGE="http://peter-murach.github.io/github/"
LICENSE="MIT"

RESTRICT="mirror test"
SLOT="0"
KEYWORDS="~amd64 ~arm"

ruby_add_rdepend '
	=dev-ruby/addressable-2.4*
	=dev-ruby/descendants_tracker-0.0*
	<dev-ruby/faraday-0.10
	>=dev-ruby/hashie-3.4
	<dev-ruby/multi_json-2.0
	>=dev-ruby/oauth2-0'
ruby_add_bdepend '
	test? ( >=dev-ruby/rspec-2.14 dev-ruby/webmock )'

RUBY_S="github-${PV}"

## ebuild generated for gem `github_api-0.13.1` by gem2ebuild on 2016-03-09
