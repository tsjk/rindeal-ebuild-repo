# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

USE_RUBY="ruby20 ruby21"

inherit ruby-fakegem

DESCRIPTION="A toolbox for developing beautiful command line clients."
HOMEPAGE="http://peter-murach.github.io/tty/"
LICENSE="MIT"

RESTRICT="mirror test"
SLOT="0"
KEYWORDS="~amd64 ~arm"

ruby_add_rdepend '
	=dev-ruby/equatable-0.5*
	=dev-ruby/pastel-0.6*
	=dev-ruby/tty-color-0.3*
	=dev-ruby/tty-cursor-0.2*
	=dev-ruby/tty-pager-0.4*
	=dev-ruby/tty-platform-0.1*
	=dev-ruby/tty-progressbar-0.8*
	=dev-ruby/tty-prompt-0.4*
	=dev-ruby/tty-screen-0.5*
	=dev-ruby/tty-spinner-0.1*
	=dev-ruby/tty-table-0.5*
	=dev-ruby/tty-which-0.1*'

## ebuild generated for gem `tty-0.4.0` by gem2ebuild on 2016-03-09
