# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_URI="github/wolfSSL"
GH_REF="v${PV}-stable"

# EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
# functions: eautoreconf
inherit autotools

DESCRIPTION="wolfSSL (formerly CyaSSL) is an implementation of TLS/SSL for embedded devices"
HOMEPAGE="https://www.wolfssl.com/ ${GH_HOMEPAGE}"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( static-libs debug
	dtls dtls-sctp
	+rng openssh opensslextra maxstrength +harden ipv6 fortress bump leanpsk leantls bigcache
)

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

src_prepare() {
    default

    eautoreconf
}

src_configure() {
	# https://www.wolfssl.com/wolfSSL/Docs-wolfssl-manual-2-building-wolfssl.html

    local myeconfargs=(
		$(use_enable static-libs static)
		$(use_enable debug)
		--disable-distro

		$(use_enable !threads singlethreaded)

		$(use_enable proto_dtls dtls)
		$(use_enable proto_dtls-sctp sctp)

		$(use_enable rng)
		$(use_enable openssh)
		$(use_enable opensslextra)

		$(use_enable ipv6-test ipv6)

		maxstrength
		harden
		ipv6
		fortress
		bump
		leanpsk
		leantls
		bigcache

    )
    econf "${myeconfargs[@]}"
}

src_compile() {
	if use test || use examples ; then
		default
	else
		emake src/libwolfssl.la
	fi
}

# src_test() {
# 	./testsuite/testsuite.test || die
# }
