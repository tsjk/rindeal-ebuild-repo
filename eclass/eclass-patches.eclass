# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: eclass-patches.eclass
# @MAINTAINER:
# Jan Chren (rindeal) <dev.rindeal+gentoo-overlay@gmail.com>
# @BLURB: Collection of overrides of functions from eclasses from the tree
# @DESCRIPTION:

case "${EAPI:-0}" in
    5|6) ;;
    *) die "Unsupported EAPI='${EAPI}' for '${ECLASS}'" ;;
esac

# ORIGIN: flag-o-matic
# PR: https://github.com/gentoo/gentoo/pull/1425
get-flag() {
	local var findflag="${1}"

	# this code looks a little flaky but seems to work for
	# everything we want ...
	# for example, if CFLAGS="-march=i686":
	# `get-flag -march` == "-march=i686"
	# `get-flag march` == "i686"
	for var in $(all-flag-vars) ; do
		# reverse loop
		set -- ${!var}
		local i=$#
		while [ $i -gt 0 ] ; do
			local f="${!i}"
			if [ "${f#-${findflag#-}}" != "${f}" ] ; then
				printf "%s\n" "${f#-${findflag}=}"
				return 0
			fi
			((i--))
		done
	done
	return 1
}

## Origin: cmake-utils.eclass
## PR: https://github.com/gentoo/gentoo/pull/1481
_ninjaopts_from_makeopts() {
	local makeopts="${1:-"${MAKEOPTS}"}" ninjaopts=()
	local jobs= keep= load=

	set -- ${makeopts}
	while (( ${#} )) ; do
		case "${1}" in
			-j|--jobs)
				if [[ -n ${2} ]] && [[ ${2} =~ ^[0-9]+$ ]] ; then
					jobs=${2}
					shift
				else
					# `man 1 make`:
					# 	If the -j option is given without an argument, make will not limit
					# 	the number of jobs that can run simultaneously.
					jobs=99
				fi
				;;
			-k|--keep-going)
				# `man 1 make`:
				# 	Continue as much as possible after an error
				# `ninja --help`:
				# 	keep going until N jobs fail
				# ninja internals:
				# 	ninja handles 0 as inifinity in this case
				keep=0
				;;
			-l|--load-average)
				if [[ -n ${2} ]] && [[ ${2} =~ ^[0-9]+\.?[0-9]*$ ]] ; then
					# ninja internals:
					# 	ninja supports floating-point numbers here
					load=${2}
					shift
				else
					# `man 1 make`:
					#	With no argument, removes a previous load limit.
					load=
				fi
				;;
			-S|--no-keep-going|--stop)
				# `make --help`:
				#	Turns off -k
				keep=
				;;
			-j*|--jobs=*|-l*|--load-average=*)
				eshopts_push -s extglob

				local arg="${1##*([^0-9])}"
				case "${1##*(-)}" in
					j*) jobs=${arg} ;;
					l*) load=${arg} ;;
				esac

				eshopts_pop
				;;
		esac
		shift
	done

	ninjaopts+=( ${jobs:+"-j"} ${jobs} )
	ninjaopts+=( ${keep:+"-k"} ${keep} )
	ninjaopts+=( ${load:+"-l"} ${load} )

	debug-print "${LINENO} ${ECLASS} ${FUNCNAME}: '${makeopts}' -> '${ninjaopts[*]}'"

	NINJAOPTS="${ninjaopts[*]}"
}

## Origin: cmake-utils.eclass
## PR: https://github.com/gentoo/gentoo/pull/1481
# @FUNCTION: _cmake_ninja_src_make
# @INTERNAL
# @DESCRIPTION:
# Build the package using ninja generator
_cmake_ninja_src_make() {
	debug-print-function ${FUNCNAME} "$@"

	[[ -e build.ninja ]] || die "build.ninja not found. Error during configure stage."

	if [[ -z ${NINJAOPTS+x} ]] ; then
		declare -g NINJAOPTS
		_ninjaopts_from_makeopts
	fi

	[[ "${CMAKE_VERBOSE}" != "OFF" ]] && NINJAOPTS+=" -v"

	set -- ninja ${NINJAOPTS} "$@"
	echo "$@"
	"$@" || die
}
