# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

USE_RUBY="ruby20 ruby21"

inherit ruby-fakegem

DESCRIPTION="Text transformations such as truncation, wrapping, aligning, indentation and "
HOMEPAGE="https://github.com/peter-murach/verse"
LICENSE="MIT"

RESTRICT="mirror test"
SLOT="0"
KEYWORDS="~amd64 ~arm"

ruby_add_rdepend '
	=dev-ruby/unicode_utils-1.4*'

## ebuild generated for gem `verse-0.4.0` by gem2ebuild on 2016-03-09
