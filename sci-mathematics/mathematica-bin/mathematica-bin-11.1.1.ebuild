# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# functions: get_version_component_range
inherit versionator
inherit xdg

DESCRIPTION="World's definitive system for modern technical computing"
HOMEPAGE="https://www.wolfram.com/mathematica/"
LICENSE="Wolfram-Mathematica"

declare -g -r -- WM_SELFEXTRACTOR_FILENAME="Mathematica_${PV}_LINUX.sh"

SLOT="$(get_version_component_range 1-2)"
SRC_URI="${WM_SELFEXTRACTOR_FILENAME}"

KEYWORDS="-* ~amd64"
IUSE_A=(
	# the docs are quite important and expected to be installed
	+doc
)

CDEPEND_A=(
# TODO
# 	'ttf-bitstream-vera' 'libxcursor' 'alsa-lib' 'libxml2'
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
# TODO
	# avahi-daemon for kernel discovery
	# glxinfo for OpenGL checks
)

RESTRICT+=" fetch strip"

inherit arrays

S="${WORKDIR}"

declare -g -r -- WM_INSTALLER_DIR="${T}/installer"
declare -g -r -- FINAL_INST_DIR="/opt/Wolfram/mathematica-${SLOT}"

pkg_nofetch() {
	einfo ""
	einfo "Please download '${WM_SELFEXTRACTOR_FILENAME}' file manually."
	einfo "Download options:"
	einfo "    - from whenever is the location on your site"
	einfo "    - from the Wolfram user portal - https://user.wolfram.com"
	einfo "    - trial version from https://www.wolfram.com/mathematica/trial"
	einfo ""
	einfo "After downloading the necessary file(s) move it to '${DISTDIR}' directory."
	einfo ""
}

pkg_setup() {
	if df "$(dirname ${WORKDIR})" | grep -q tmpfs ; then
		einfo ""
		einfo "Building ${CATEGORY}/${PN} takes more than 8GB of space."
		einfo "Building in a tmpfs may not work."
		einfo ""
	fi
}

my_run_selfextractor() {
	# NOTE: the order of arguments is fixed because of a suboptimal argument handling inside the Makeself script
	# NOTE: you can get all possible arguments by inspecting the script which is in the first 9kB of the file, so
	#   try running something like `head -c $((1024*9)) <SCRIPT> > Makeself.sh`

	# -h | --help)
    # --info)
    # --dumpconf)
    # --lsm)
    # --list)
    # --check)
    # --confirm)
    # --keep)
    # --target)
    # --nox11)
    # --nochown)
    # --xwin)
    # --phase2)

	set -- sh "${DISTDIR}/${WM_SELFEXTRACTOR_FILENAME}" "${@}"
	echo "Running: $@"
	"$@" || die
}

src_unpack() {
	local c
	for c in info dumpconf ; do
		my_run_selfextractor --$c | awk '{ print ( ( NR > 1 ) ? "    " : "" ), $0 }'
		assert
	done

	local args=(
		# after the extraction a y/n prompt ask whether to run the installer script
		--confirm
		--keep
		# extract installer here
		--target "${WM_INSTALLER_DIR}"
		# Do not spawn an extra terminal
		--nox11
	)
	# NOTE: due to a bug in the Makeself script deployed by Wolfram, it's needed to supply `SETUP_NOCHECK=1`,
	#   so that `--confirm` argument works as expected
	#
	SETUP_NOCHECK=1 \
		my_run_selfextractor "${args[@]}" < <(printf 'n\n')
	echo # the selfextractor won't spit a newline

	declare -g -r -- WM_INSTALLER_PATH="${WM_INSTALLER_DIR}/$(source <(my_run_selfextractor --dumpconf); echo "${SCRIPT}")"
	[[ -x "${WM_INSTALLER_PATH}" ]] || die "Installer executable check failed"
}

src_prepare() {
	default

	# DEBUG: make a backup of the original file to ease debugging
	(( WM_DEBUG == 1 )) && ecp "${WM_INSTALLER_PATH}" "${WM_INSTALLER_PATH}.bak"

	# replace the stderr logging exec call with one that prints the stderr to the console as well as to the logfile
	# https://stackoverflow.com/a/44710375/2566213
	#sed -r '0,/^[ \t]*exec 2/ {
			#s|exec 2.*|exec 2> >( while read -r line; do printf "%s\\n" "${line}" >\&2; printf "%s\\n" "${line}" >> "${ErrorFile}"; done )|
		#}' -i -- "${WM_INSTALLER_PATH}" || die
	# this version just deletes the call altogether
	sed -r '0,/^[ \t]*exec 2/ { /exec 2/d }' -i -- "${WM_INSTALLER_PATH}" || die
	# enable DEBUG without enabling -verbose
	sed 's|DEBUG="false"|DEBUG=true|' -i -- "${WM_INSTALLER_PATH}" || die
	# remove duplicated DEBUG=true lines, normally the other ones would go to a logfile,
	# but since we deleted the redirection both ends up in the console
	sed '/echo "<< .*>&2/d' -i -- "${WM_INSTALLER_PATH}" || die
}

my_run_installer() {
	local installer=(
		bash "${WM_INSTALLER_PATH}"

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

		-auto
		-execdir="${ED}/${FINAL_INST_DIR}/bin"
		-targetdir="${ED}/${FINAL_INST_DIR}"
		# no .desktop files, icons, ... - it's buggy!
		# https://github.com/rindeal/gentoo-overlay/issues/172
		-nodesktop
	)
	(( WM_DEBUG == 1 )) && installer+=( -debug )

	echo "Running: '${installer[*]}'"
	"${installer[@]}" || die
}

my_cleanup_inst_dir() {
	if ! use doc ; then
		einfo "Deleting documentation ..."
		NO_V=1 erm -r Documentation
	fi

	einfo "Deleting 32-bit Linux files and files for other OSes ..."
	find SystemFiles AddOns -type d -\( -name "Windows*" -o -name "MacOSX*" -o -name "Linux" -\) -print0 | \
	while read -d '' -r d ; do
		if [[ "${d}" == *"/Linux"* ]] ; then
			# delete only if a 64-bit variant exists
			if [[ -d "${d}-x86-64" ]] ; then
				erm -r "${d}"
				continue
			fi
		fi

		local m
		for m in {Windows,MaxOSX}{,-x86-64} ; do
			# delete only if the dir fully matches
			if [[ "${d}" == *"/${m}/"* ]] || [[ "${d}" == *"/${m}" ]] ; then
				erm -r "${d}"
				continue 2
			fi
		done
	done
	assert
}

my_fixup_inst_dir() {
	einfo "Fixing symbolic links..."
	local l
	for l in "bin"/* ; do
		if [[ -L "${l}" ]] ; then
			local old_path="$( readlink -f "${l}" )"
			local new_path="${EROOT}${old_path##"${D}"}"
			echo "Fixing link '${l}': '${old_path}' -> '${new_path}'"
			ln -f -s "${new_path}" "${l}" || die
		fi
	done
}

src_install() {
	my_run_installer

	cd "${ED}/${FINAL_INST_DIR}" || die

	local f='Executables/mathematica'
	if [[ ! -x "${f}" ]] || (( $(stat --printf=%s "${f}") < 100 ))
	then
		die "File '${f}' not found, extraction of the files probably failed, try to increase the free space in PORTAGE_TMPDIR ('${PORTAGE_TMPDIR}') dir to at least 10GB."
	fi

	my_cleanup_inst_dir
	my_fixup_inst_dir

	insinto "/usr/share/mime/packages/"
	doins "SystemFiles/Installation"/*.xml

	local make_desktop_entry_args=(
		"${EPREFIX}${FINAL_INST_DIR}/bin/Mathematica %F"	# exec
		"Wolfram Mathematica ${SLOT}"	# name
		"${PN%%-bin}"	# icon
		'Science;Math;NumericalAnalysis;DataVisualization;'	# categories
	)
	local make_desktop_entry_extras=()
	make_desktop_entry "${make_desktop_entry_args[@]}" \
		"$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"

	einfo "Installing icons ..."
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

	einfo "Installing man pages ..."
	doman SystemFiles/SystemDocumentation/Unix/*.1

	einfo "Fixing file permissions ..."
	NO_V=1 echmod --recursive go-w .
}

QA_PREBUILT="*"
