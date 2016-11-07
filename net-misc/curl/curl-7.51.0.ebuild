# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_URI="github"
GH_REF="curl-${PV//./_}"

inherit git-hosting
# functions: rindeal:dsf, rindeal:dsf:prefix_flags
inherit rindeal-utils
# functions: eautoreconf
inherit autotools
# functions: prune_libtool_files
inherit eutils
# functions: eprefixify
inherit prefix

DESCRIPTION="Command line tool and library for transferring data with URLs"
HOMEPAGE="https://curl.haxx.se/ ${GH_HOMEPAGE}"
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=(
	curldebug +largefile libgcc +rt +symbol-hiding versioned-symbols static-libs test

	libcurl-option manual +verbose

	ipv6 +unix-sockets +zlib ares threaded-resolver idn gssapi psl spnego kerberos ntlm ntlm-wb tls-srp http2

	+cookies +crypto-auth metalink proxy ssh2

	$(rindeal:dsf:prefix_flags \
		"protocol_" \
		all +http +https +ftp +ftps +file telnet ldap ldaps dict tftp gopher pop3 pop3s imap imaps \
		smb smbs smtp smtps rtsp rtmp scp sftp)

	+ssl
	$(rindeal:dsf:prefix_flags \
		"ssl_" \
		axtls gnutls libressl mbedtls nss +openssl polarssl)
)

# tests lead to lots of false negatives, bug gentoo#285669
RESTRICT+=" test"

CDEPEND_A=(
	"protocol_ldap? ( net-nds/openldap )"
	"ssl? ("
		"$(rindeal:dsf \
			"ssl_openssl|ssl_libressl|ssl_gnutls|ssl_polarssl" \
				"app-misc/ca-certificates")"

		"ssl_axtls?		( net-libs/axtls )"
		"ssl_gnutls?	("
			"net-libs/gnutls:0=[static-libs?]"
			"dev-libs/nettle:0="
		")"
		"ssl_libressl?	( dev-libs/libressl:0=[static-libs?] )"
		"ssl_mbedtls?	( net-libs/mbedtls:0= )"
		"ssl_openssl?	( dev-libs/openssl:0=[static-libs?] )"
		"ssl_nss?		( dev-libs/nss:0 )"
		"ssl_polarssl?	( net-libs/polarssl:0= )"
	")"
	"http2?	( net-libs/nghttp2 )"
	"idn?	( net-dns/libidn2:0[static-libs?] )"
	"ares?	( net-dns/c-ares:0 )"
	"kerberos?	( >=virtual/krb5-0-r1 )"
	"metalink?	( >=media-libs/libmetalink-0.1.1 )"
	"protocol_rtmp?	( media-video/rtmpdump )"
	"ssh2?	( net-libs/libssh2[static-libs?] )"
	"zlib? ( sys-libs/zlib )"
	"protocol_ldap? ( net-nds/openldap )"
	"protocol_ldaps? ( net-nds/openldap[ssl] )"
	"psl? ( net-libs/libpsl )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
	"test? ("
		"sys-apps/diffutils"
		"dev-lang/perl"
	")"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	# c-ares must be disabled for threads
	"threaded-resolver? ( !ares )"
	"ssl? ("
		"^^ ("
			$(rindeal:dsf:prefix_flags \
				"ssl_" \
				axtls gnutls libressl mbedtls nss openssl polarssl)
		")"
	")"

	"spnego? ( || ( crypto-auth gssapi ) )"
	"kerberos? ( crypto-auth gssapi )"
	"ntlm? ( crypto-auth ssl )"
	"ntlm-wb? ( ntlm protocol_http )"

	"protocol_https?	( protocol_http ssl )"
	"protocol_ftps?		( protocol_ftp ssl )"
	"protocol_ldaps?	( protocol_ldap )"
	"protocol_pop3s?	( protocol_pop3 ssl )"
	"protocol_imaps?	( protocol_imap ssl )"
	"protocol_smb?		( crypto-auth ^^ ( $(rindeal:dsf:prefix_flags "ssl_" openssl libressl gnutls nss) ) )"
	"protocol_smbs?		( protocol_smb ssl )"
	"protocol_smtps?	( protocol_smtp ssl )"
	"protocol_scp?		( ssh2 )"
	"protocol_sftp?		( ssh2 )"
)

inherit arrays

src_prepare() {
	eapply "${FILESDIR}/${PN}-7.30.0-prefix.patch"
	eapply "${FILESDIR}/${PN}-respect-cflags-3.patch"
	eapply "${FILESDIR}/${PN}-fix-gnutls-nettle.patch"
	eapply_user

	# gentoo#382241
	sed -e '/LD_LIBRARY_PATH=/d' -i -- configure.ac || die

	eprefixify curl-config.in

	eautoreconf
}

src_configure() {
	# We make use of the fact that later flags override earlier ones
	# So start with all ssl providers off until proven otherwise
	local my_econf_args=(
		--disable-debug # just sets -g* flags
		--disable-optimize # just sets -O* flags
		--enable-warnings
		--disable-werror
		--disable-soname-bump
		--with-zsh-functions-dir="${EPREFIX}"/usr/share/zsh/site-functions

		$(use_enable curldebug)
		$(use_enable largefile)
		$(use_enable libgcc)
		$(use_enable rt)
		$(use_enable symbol-hiding)
		$(use_enable versioned-symbols)
		$(use_enable static-libs static)
		# --with-pic=yes|no|default

		$(use_enable libcurl-option)
		$(use_enable manual)
		$(use_enable verbose)

		$(use_enable ipv6)
		$(use_enable unix-sockets)
		$(use_with zlib)
		$(use_enable ares) # =PATH
		$(use_enable threaded-resolver)
		$(use_with idn libidn2)
		"$(use_with gssapi gssapi "${EPREFIX}"/usr)"
		$(use_with psl libpsl)
		$(use_enable ntlm-wb)
		$(use_enable tls-srp)
		$(use_with http2 nghttp2)

		$(use_enable cookies)
		$(use_enable crypto-auth)
		$(use_with metalink libmetalink)
		$(use_enable proxy)
		$(use_with ssh2 libssh2)
	)

	### Protocols
	my_use_protocol() {
		usex protocol_all protocol_all protocol_$1
	}
	my_econf_args+=(
		"$(use_enable $(my_use_protocol http)	http)"
		"$(use_enable $(my_use_protocol ftp)	ftp)"
		"$(use_enable $(my_use_protocol file)	file)"
		"$(use_enable $(my_use_protocol telnet)	telnet)"
		"$(use_enable $(my_use_protocol ldap)	ldap)"
		"$(use_enable $(my_use_protocol ldaps)	ldaps)"
		"$(use_enable $(my_use_protocol dict)	dict)"
		"$(use_enable $(my_use_protocol tftp)	tftp)"
		"$(use_enable $(my_use_protocol gopher)	gopher)"
		"$(use_enable $(my_use_protocol pop3)	pop3)"
		"$(use_enable $(my_use_protocol imap)	imap)"
		"$(use_enable $(my_use_protocol smb)	smb)"
		"$(use_enable $(my_use_protocol smtp)	smtp)"
		"$(use_enable $(my_use_protocol rtsp)	rtsp)"
		"$(use_with   $(my_use_protocol rtmp)	librtmp)"
	)

	### SSL
	my_use_ssl() {
		usex ssl ssl_$1 ssl
	}
	my_econf_args+=(
		# "Don't use the built in CA store of the SSL library"
		--without-ca-fallback
		--with-ca-bundle="${EPREFIX}"/etc/ssl/certs/ca-certificates.crt
		--without-winssl	# disable Windows native SSL/TLS
		--without-darwinssl	# disable Apple OS native SSL/TLS
		--without-winidn	# disable Windows native IDN

		$(use_with $(my_use_ssl axtls)	axtls)
		$(use_with $(my_use_ssl gnutls)	gnutls)
		$(use_with $(my_use_ssl gnutls)	nettle)
		$(use_with $(my_use_ssl libressl)	ssl)
		$(use_with $(my_use_ssl mbedtls)	mbedtls)
		$(use_with $(my_use_ssl nss)	nss)
		$(use_with $(my_use_ssl polarssl)	polarssl)
		$(use_with $(my_use_ssl openssl)	ssl)
	)
	if use ssl_openssl || use ssl_libressl || use ssl_gnutls || use ssl_polarssl ; then
		my_econf_args+=( --with-ca-path="${EPREFIX}"/etc/ssl/certs )
	else
		my_econf_args+=( --without-ca-path )
	fi

	my_econf_args+=(
		$(use_enable crypto-auth)
		$(use_enable ntlm-wb) # =FILE
		$(use_enable tls-srp)
	)

	econf "${my_econf_args[@]}"

	## Fix up the pkg-config file to be more robust.
	## https://github.com/curl/curl/issues/864
	local priv=() libs=()
	if use zlib ; then
		libs+=( "-lz" )
		priv+=( "zlib" )
	fi
	if use http2 ; then
		libs+=( "-lnghttp2" )
		priv+=( "libnghttp2" )
	fi
	if use ssl_openssl ; then
		libs+=( "-lssl" "-lcrypto" )
		priv+=( "openssl" )
	fi
	grep -q Requires.private libcurl.pc && die "need to update ebuild"
	libs=$(printf '|%s' "${libs[@]}")
	sed -r -e "/^Libs.private/s:(${libs#|})( |$)::g" \
		-i -- libcurl.pc || die
	echo "Requires.private: ${priv[*]}" >> libcurl.pc
}

src_install() {
	emake DESTDIR="${D}" install

	local DOCS=( CHANGES README docs/FEATURES docs/INTERNALS.md
		docs/MANUAL docs/FAQ docs/BUGS docs/CONTRIBUTE.md )
	einstalldocs

	prune_libtool_files
}
