# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

USE_RUBY="ruby20 ruby21"

inherit ruby-fakegem

DESCRIPTION="A flexible and intuitive table generator"
HOMEPAGE="http://peter-murach.github.io/tty/"
LICENSE="MIT"

RESTRICT="mirror test"
SLOT="0"
KEYWORDS="~amd64 ~arm"

ruby_add_rdepend '
	=dev-ruby/equatable-0.5*
	=dev-ruby/necromancer-0.3*
	=dev-ruby/pastel-0.6*
	=dev-ruby/tty-screen-0.5*
	=dev-ruby/unicode_utils-1.4*
	=dev-ruby/verse-0.4*'

## ebuild generated for gem `tty-table-0.5.0` by gem2ebuild on 2016-03-09
