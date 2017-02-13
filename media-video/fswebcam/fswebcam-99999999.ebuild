# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GH_URI="github/fsphil"

inherit git-hosting autotools

DESCRIPTION="Neat and simple webcam app"
HOMEPAGE="http://www.sanslogic.co.uk/fswebcam/ ${HOMEPAGE}"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS=""
IUSE_A=(
	# allow capturing of 2^32 frames
	+32bit-buffer
	# V4L1 support
	v4l1
	# V4L2 support
	+v4l2
)

CDEPEND="media-libs/gd[jpeg,png,truetype]"
DEPEND="${CDEPEND}
	virtual/pkgconfig"
RDEPEND="${CDEPEND}"

inherit arrays

src_prepare() {
	default

	# pkg-config --libs
	sed -e "/LDFLAGS=/ s|-ld|$(pkg-config --libs gdlib)|" \
		-i -- configure.ac || die

	sed -e '/install -m .*fswebcam.1./d' \
		-i -- configure.ac || die

	eautoreconf
}

src_configure() {
	local myeconfargs=(
		$(use_enable 32bit-buffer)
		$(use_enable v4l1)
		$(use_enable v4l2)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	doman "${PN}.1"
}
