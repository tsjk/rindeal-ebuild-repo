# Copyright 2015-2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

inherit git-r3 autotools

DESCRIPTION="An open-source multi-platform crash reporting system"
HOMEPAGE="https://chromium.googlesource.com/breakpad/breakpad"
LICENSE="BSD"
EGIT_REPO_URI="https://chromium.googlesource.com/breakpad/breakpad"

SLOT="0"
KEYWORDS="~amd64"

src_unpack() {
	git-r3_src_unpack

	local lsc_url='https://chromium.googlesource.com/linux-syscall-support'
	git-r3_fetch "$lsc_url"
	git-r3_checkout "$lsc_url" "${S}/src/third_party/lss"
}
src_prepare() {
	eapply_user

	eautoreconf
	eautomake
}

src_install() {
	default

	# Install headers that some programs require to build.
	local include_dir="${EROOT}usr/include/breakpad"
	cd "${S}/src"
	insinto "${include_dir}/common"
	doins 'google_breakpad/common/'*.h
	cd 'client/linux'
	insinto "${include_dir}"
	doins 'handler/exception_handler.h'
	insinto "${include_dir}/client/linux/minidump_writer"
	doins 'minidump_writer/'*.h
	insinto "${include_dir}/client/linux/crash_generation"
	doins 'crash_generation/'*.h
	insinto "${include_dir}/client/linux/dump_writer_common"
	doins 'dump_writer_common/'*.h
}
