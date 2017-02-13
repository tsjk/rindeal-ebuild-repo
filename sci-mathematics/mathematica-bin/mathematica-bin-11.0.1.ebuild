# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

inherit versionator
inherit xdg

DESCRIPTION="World's definitive system for modern technical computing"
HOMEPAGE="https://www.wolfram.com/mathematica/"
LICENSE="Wolfram-Mathematica"

SLOT="$(get_version_component_range 1-2)"
MATHEMATICA_INSTALLER="Mathematica_${PV}_LINUX.sh"
SRC_URI="${MATHEMATICA_INSTALLER}"

KEYWORDS="-* ~amd64"
IUSE_A=( doc )

CDEPEND_A=(
# 	'ttf-bitstream-vera' 'libxcursor' 'alsa-lib' 'libxml2'
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	# avahi-daemon for kernel discovery
	# glxinfo for OpenGL checks
)

RESTRICT+=" fetch strip binchecks"

inherit arrays

S="${WORKDIR}"

pkg_nofetch() {
	einfo ""
	einfo "Please download '${MATHEMATICA_INSTALLER}' manually."
	einfo "Download options:"
	einfo "    - from whenever is the location on your site"
	einfo "    - from the Wolfram user portal - https://user.wolfram.com"
	einfo "    - trial version from https://www.wolfram.com/mathematica/trial"
	einfo ""
	einfo "After downloading the necessary file(s) move it to '${DISTDIR}' directory."
	einfo ""
}

my_run_installer() {
	# Full reference: https://reference.wolfram.com/language/tutorial/InstallingMathematica.html#284919301
	#
	# -auto				force the installation to proceed automatically without prompting the user for any information
	# -createdir=(y|n)	specify whether or not to create the directories specified by the options -targetdir and -execdir
	# -execdir=dir		specify the path to be used for the symbolic links to the executable scripts
	# -help				display information about the installer options
	# -method=type		define the type of installation you would like to perform
	# -overwrite=(y|n)	specify whether the installer should overwrite any files that already exist in the target directory
	# -platforms=value	specify the system ID of the Linux platform or platforms for which you want to do the installation
	# -selinux=value	specify whether the installer should attempt to modify the security context of any included libraries so that it will function properly
	# -silent			force an automatic installation (equivalent to the -auto option)
	# -targetdir=dir	specify the installation directory
	# -verbose			display detailed information about the files and directories being installed

	set -- /bin/sh "${DISTDIR}/${MATHEMATICA_INSTALLER}" "${@}"
	echo "Running: $@"
	"$@" || die
}

pkg_setup() {
	if df "$(dirname ${WORKDIR})" | grep -q tmpfs ; then
		einfo ""
		einfo "Building ${CATEGORY}/${PN} takes more than 8GB of space."
		einfo "Building in a tmpfs (e.g. /tmp when mounted into RAM) may not work."
		einfo ""
	fi

	my_run_installer --info
}

MY_INST_DIR="/opt/Wolfram/mathematica-${SLOT}"

src_install() {
	local installer_args=(
		## Makeself args
		# Do not spawn an xterm
		--nox11
		# extract installer here
		--target "${T}/installer"

		--
		## mathematica installer args
		-auto
		-execdir="${ED}/${MY_INST_DIR}/bin"
		-targetdir="${ED}/${MY_INST_DIR}"
	)
	my_run_installer "${installer_args[@]}"

	if [[ ! -x "Executables/mathematica" ]] || (( $(stat --printf=%s "Executables/mathematica") < 100 ))
	then
		die "Extraction of the files failed, try to increase the free space in PORTAGE_TMPDIR dir to at least 13GB."
	fi

	cd "${ED}/${MY_INST_DIR}" || die

	if ! use doc ; then
		einfo "Deleting documentation ..."
		RM_V=0 erm -r Documentation
	fi

	einfo "Deleting 32-bit files ..."
	local d
	find SystemFiles AddOns -type d -name "Linux" -print0 | \
	while read -d '' -r d ; do
		[[ -d "${d}-x86-64" ]] && rm -v -r "${d}"
	done
	assert

	einfo "Deleting files for different OSes ..."
	find SystemFiles AddOns -type d -\( -name "Windows*" -o -name "MacOSX*" -\) -print0 | \
		xargs -0 rm -v -r
	assert

	einfo "Fixing symbolic links..."
	local l
	for l in "bin"/* ; do
		if [[ -L "${l}" ]] ; then
			local old_path="$(readlink -f "${l}")"
			local new_path="/${old_path##"${D}"}"
			echo "Fixing link '${old_path}' -> '${new_path}'"
			ln -f -s "${new_path}" "${l}" || die
		fi
	done

	insinto "/usr/share/mime/packages/"
	doins "SystemFiles/Installation"/*.xml

	local make_desktop_entry_args=(
		"${EPREFIX}${MY_INST_DIR}/bin/Mathematica %F"	# exec
		"Wolfram Mathematica ${SLOT}"	# name
		"${PN%%-bin}"	# icon
		'Science;Math;NumericalAnalysis;DataVisualization;'	# categories
	)
	local make_desktop_entry_extras=()
	make_desktop_entry "${make_desktop_entry_args[@]}" \
		"$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"

	einfo "Copying icons ..."
	epushd "SystemFiles/FrontEnd/SystemResources/X"
	local s
	for s in 32 64 128 ; do
		newicon -s ${s} "App-${s}.png" "${PN%-bin}.png"

		insinto "/usr/share/icons/hicolor/${s}x${s}/mimetypes/"
		newins "vnd.wolfram.cdf-${s}.png"					"application-vnd.wolfram.cdf.png"
		newins "vnd.wolfram.mathematica.package-${s}.png"	"application-vnd.wolfram.mathematica.package.png"
		newins "vnd.wolfram.nb-${s}.png"					"application-vnd.wolfram.nb.png"
		newins "vnd.wolfram.player-${s}.png"				"application-vnd.wolfram.player.png"
		newins "vnd.wolfram.wl-${s}.png"					"application-vnd.wolfram.wl.png"
	done
	epopd

	einfo "Copying man pages ..."
	doman SystemFiles/SystemDocumentation/Unix/*.1

	einfo "Fixing file permissions ..."
	chmod --recursive go-w . || die
}

QA_PREBUILT="*"
