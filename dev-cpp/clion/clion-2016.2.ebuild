# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

JBIJ_PN_PRETTY='CLion'
JBIJ_URI="cpp/CLion-${PV}"

inherit jetbrains-intellij

DESCRIPTION="A complete toolset for C and C++ development"

IUSE="+python system-cmake system-gdb"

RDEPEND="
	system-cmake? ( >=dev-util/cmake-3.2 )
	system-gdb? ( >=sys-devel/gdb-7.8 )"

src_unpack() {
	local JBIJ_TAR_EXCLUDE=()
	use python         || JBIJ_TAR_EXCLUDE+=( 'plugins/python' )
	use system-cmake   && JBIJ_TAR_EXCLUDE+=( 'bin/cmake' )
	use system-gdb     && JBIJ_TAR_EXCLUDE+=( 'bin/gdb' )

	jetbrains-intellij_src_unpack
}

src_prepare() {
	default

	cd "${S}"/plugins/tfsIntegration/lib/native || die
	{
		eshopts_push -s extglob
		# use eval() because of syntax errors
		eval 'rm -rvf !(linux)' || die
		eshopts_pop

		cd linux || die
		{
			rm -rvf ppc || die
			use amd64	|| { rm -rvf x86_64	|| die ;}
			use arm		|| { rm -rvf arm	|| die ;}
			use x86		|| { rm -rvf x86	|| die ;}
		}
	}
}

src_install() {
	local JBIJ_DESKTOP_EXTRAS=(
		"MimeType=text/plain;text/x-c;text/x-h;" # MUST end with semicolon
	)

	jetbrains-intellij_src_install

	cd "${D}/${JBIJ_INSTALL_DIR}" || die
	# globbing doesn't work with `fperms()`'
	use system-cmake	|| { chmod -v a+x bin/cmake/bin/* || die ;}
	use system-gdb		|| { chmod -v a+x bin/gdb/bin/*	  || die ;}
}
