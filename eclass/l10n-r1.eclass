# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: l10n-r1.eclass
# @MAINTAINER:
#   Jan Chren <dev.rindeal+gentoo@gmail.com>
# @BLURB: convenience functions to handle localizations
# @DESCRIPTION:
# The l10n-r1 (localization) eclass offers a number of functions to more
# conveniently handle localizations (translations) offered by packages.
# These are meant to prevent code duplication for such boring tasks as
# determining the cross-section between the user's set LINGUAS and what
# is offered by the package; and generating the right list of l10n_*
# USE flags.

if [ -z "${_L10N_R1_ECLASS}" ] ; then

[ -v _L10N_ECLASS ] && die "You've inheritted both l10n.eclass and l10n-r1.eclass"

case "${EAPI:-0}" in
	6) ;;
	*) die "Unsupported EAPI='${EAPI}' (unknown) for '${ECLASS}'" ;;
esac


_l10n_var_is_defined() {
	# https://unix.stackexchange.com/a/56846/53317
	eval "[[ \" \${!${1}*} \" == *\" ${1} \"* ]]"
}

_l10n_var_is_type() {
	local type="${1:0:1}" varname="${2}"

	case "${type}" in
		'-' | 's' ) type='-' ;;
		'a' ) ;;
		'A' ) ;;
		'i' ) ;;
		* ) die "Invalid type: '${type}'" ;;
	esac

	_l10n_var_is_defined "${varname}" || die "Variable '${varname}' doesn't exist"

	[[ "$(declare -p "${varname}" 2>/dev/null)" == "declare -${type}"* ]]
}

# Usage: _l10n_var_ensure_type <type> <varname>
# Types:
# 	`a` = array
# 	`A` = associative array
# 	`i` = integer
# 	`s` = string
#
_l10n_var_ensure_type() {
	local type="${1:0:1}" varname="${2}"
	local typename

	case "${type}" in
		'-' | 's' ) typename='a string' ; type='-' ;;
		'a' ) typename='an array' ;;
		'A' ) typename='an associative array' ;;
		'i' ) typename='an integer' ;;
		* ) die "Invalid type: '${type}'" ;;
	esac

	if ! _l10n_var_is_type "${type}" "${varname}" ; then
		die "Variable '${varname}' must be ${typename}"
	fi
}


## l10n.eclass compatibility layer
## TODO: remove in EAPI7
if (( EAPI <= 6 )) ; then
	_eqawarn_once() {
		if [[ ${EBUILD_PHASE_FUNC} = pkg_pretend ]] ; then
			eqawarn "${@}"
		fi
	}

	if [[ -v PLOCALES ]] ; then
		_eqawarn_once "PLOCALES is deprecated, please convert it to L10N_LOCALES array"
		if _l10n_var_is_type s PLOCALES ; then
			declare -g -a L10N_LOCALES=( ${PLOCALES} )
		elif _l10n_var_is_type a PLOCALES ; then
			declare -g -a L10N_LOCALES=( ${PLOCALES[@]} )
		else
			die
		fi
	fi

	if [[ -v PLOCALE_BACKUP ]] ; then
		_eqawarn_once "PLOCALE_BACKUP is deprecated, please convert it to L10N_LOCALES_BACKUP"
		declare -g L10N_LOCALES_BACKUP="${PLOCALE_BACKUP}"
	fi

	if [[ -v PLOCALES_MASK ]] ; then
		_eqawarn_once "PLOCALES_MASK is deprecated, please convert it to L10N_LOCALES_MASK array"
		declare -g -a L10N_LOCALES_MASK=( "${PLOCALES_MASK[@]}" )
	fi

	if [[ -v PLOCALES_MAP || -v PLOCALES_MAP[@] ]] ; then
		_eqawarn_once "PLOCALES_MAP is deprecated, please rename it to L10N_LOCALES_MAP associative array"
		# copy assoc array it - https://stackoverflow.com/a/8881121/2566213
		_a="$(declare -p PLOCALES_MAP)"
		eval eval declare -g -A L10N_LOCALES_MAP="${_a#*=}"
		unset _a
	fi

	l10n_find_plocales_changes() {
		eqawarn "Function '${FUNCNAME[0]}' is deprecated, please use 'l10n_find_changes_in_dir' instead"
		l10n_find_changes_in_dir "${@}"
	}

	l10n_for_each_locale_do() {
		eqawarn "Function '${FUNCNAME[0]}' is deprecated"

		local code
		read -r -d '' code <<-'EOF'
		local l locales
		l10n_get_locales locales app on
		for l in ${locales} ; do
			"${@}" "${l}" || die
		done
		EOF
		eqawarn "${code}"
		eval "${code}"
	}

	l10n_for_each_disabled_locale_do() {
		eqawarn "Function '${FUNCNAME[0]}' is deprecated."
		eqawarn "Please replace it with a code like this:"

		local code
		read -r -d '' code <<-'EOF'
		local l locales
		l10n_get_locales locales app off
		for l in ${locales} ; do
			"${@}" "${l}" || die
		done
		EOF
		eqawarn "${code}"
		eval "${code}"
	}
fi


# @ECLASS-VARIABLE: L10N_LOCALES
# @DEFAULT_UNSET
# @DESCRIPTION:
# Array listing the locales for which localizations are offered by
# the package. Check profiles/desc/linguas.desc to see if the locales
# are listed there. Add any missing ones there.
#
# This variable is required and must be set before inherit.
#
# Example:
# @CODE
# L10N_LOCALES=( cy de el_GR en_US pt_BR vi zh_CN )
# @CODE

if [[ -z "${L10N_LOCALES}" ]] ; then
	die "L10N_LOCALES is not defined or empty"
fi
debug-print "${ECLASS}: $(declare -p L10N_LOCALES)"
_l10n_var_ensure_type a L10N_LOCALES


# @ECLASS-VARIABLE: L10N_LOCALES_BACKUP
# @DEFAULT_UNSET
# @DESCRIPTION:
# In some cases the package fails when none of the offered L10N_LOCALES are
# selected by the user. In that case this variable should be set to a
# default locale (usually 'en' or 'en_US') as backup.
#
# Example:
# @CODE
# L10N_LOCALES_BACKUP="en_US"
# @CODE

if [[ -n ${L10N_LOCALES_BACKUP} ]] ; then
	debug-print "${ECLASS}: $(declare -p L10N_LOCALES_BACKUP)"
	_l10n_var_ensure_type s L10N_LOCALES_BACKUP
fi


# @ECLASS-VARIABLE:	L10N_LOCALES_MAP
# @DEFAULT:	Default L10N_LOCALES_MAP has values same as keys
# @DESCRIPTION:	Keys are Gentoo lang codes, values are IFS separated lists of app lang codes
# 				At least one value for each key must be valid and really exist in a package.
#
# Example:
# @CODE
# L10N_LOCALES_MAP+=( ['en']='eng' ['de']='ger german' )
# @CODE

if [[ ! -v L10N_LOCALES_MAP[@] ]] ; then
	declare -g -A L10N_LOCALES_MAP=()
fi
debug-print "${ECLASS}: $(declare -p L10N_LOCALES_MAP)"
_l10n_var_ensure_type A L10N_LOCALES_MAP

# generate deault map
for _l in "${L10N_LOCALES[@]}" ; do
	# overwrite only if not already set
	if [[ -z "${L10N_LOCALES_MAP["${_l}"]}" ]] ; then
		L10N_LOCALES_MAP+=(
			# values are same as keys by default
			["${_l}"]="${_l}"
		)
	fi
done
unset _l
debug-print "${ECLASS}: generated: $(declare -p L10N_LOCALES_MAP)"


# @ECLASS-VARIABLE: L10N_LOCALES_MASK
# @DEFAULT_UNSET
# @DESCRIPTION:
# Array of locales which will be turned off and ignored when looking for changes.
# Useful for some exotic locales, which are not supported in Gentoo.

declare -g -A _L10N_LOCALES_MASK=() # lookup table

if [[ -v L10N_LOCALES_MASK ]] ; then
	debug-print "${ECLASS}: $(declare -p L10N_LOCALES_MASK)"
	_l10n_var_ensure_type a L10N_LOCALES_MASK

	for _l in "${L10N_LOCALES_MASK[@]}" ; do
		[[ -v L10N_LOCALES_MAP["${_l}"] ]] && \
			die "Error: L10N_LOCALES_MASK must not contain values from L10N_LOCALES_MAP, but '${_l}' was found in both"
		_L10N_LOCALES_MASK+=( ["${_l}"]= )
	done
	unset _l
fi


# Add l10n_* USE flags useflags.
# This parameter expansion uses a BASH feature called 'anchoring'.
IUSE+=" ${L10N_LOCALES[@]/#/l10n_}"


_l10n_generate_onoff_lists() {
	debug-print-function ${FUNCNAME}
	local v

	# bail out if already set
	for v in _{app,global}_locales_{on,off} ; do
		[[ -v ${v} ]] && return 0
	done

	# - "on" locales are enabled via USE flag
	# - _global_locales_* are those from Gentoo lang codes
	# - _app_locales_* are those specified via a mapping in L10N_LOCALES_MAP
	declare -g _global_locales_on= _global_locales_off=
	declare -g _app_locales_on= _app_locales_off=

	local l
	for l in "${L10N_LOCALES[@]}" ; do
		local ll="${L10N_LOCALES_MAP["${l}"]}"
		if use l10n_${l} ; then
			_global_locales_on+=" ${l} "
			_app_locales_on+=" ${ll} "
		else
			_global_locales_off+=" ${l} "
			_app_locales_off+=" ${ll} "
		fi
	done

	# handle L10N_LOCALES_BACKUP
	if [[ -n "${L10N_LOCALES_BACKUP}" && -z "${_global_locales_on}" ]] ; then
		# make L10N_LOCALES_BACKUP the only lang that is _on_
		_global_locales_on="${L10N_LOCALES_BACKUP}"
		_app_locales_on="${L10N_LOCALES_MAP["${L10N_LOCALES_BACKUP}"]}"

		# exclude L10N_LOCALES_BACKUP from _off_ lists
		# https://bugs.gentoo.org/show_bug.cgi?id=547790
		_global_locales_off="${_global_locales_off/" ${_global_locales_on} "}"
		_app_locales_off="${_app_locales_off/" ${_app_locales_on} "}"
	fi

	# disable masked locales
	_global_locales_off+=" ${L10N_LOCALES_MASK[*]} "
	_app_locales_off+=" ${L10N_LOCALES_MASK[*]} "

	# trim/squeeze spaces and sort
	for v in _{app,global}_locales_{on,off} ; do
		declare -g ${v}="$(echo $(printf "%s\n" ${!v} | LC_ALL=C sort))"
	done
}

# @FUNCTION: l10n_get_locales
# @USAGE: dst_var [global|app] [on|off]
# @DESCRIPTION:
# Determine which L10N USE flags the user has enabled that are offered
# by the package, as listed in L10N_LOCALES, and return them. In case no locales
# are selected, fall back on L10N_LOCALES_BACKUP. When the disabled argument is
# given, return the disabled useflags instead of the enabled ones.
l10n_get_locales() {
	local _dst_var="${1}" ; shift
	local _type="${1:-"global"}" ; shift
	local _flag="${1:-"on"}" ; shift

	[[ -z "${_dst_var}" ]] && die "dst_var is empty"

	_l10n_generate_onoff_lists

	# _src_var will contain one of _{global,l10n}_locales_{on,off}
	local _src_var=
	case "${_type}" in
		'global') _src_var+="_global" ;;
		'app') _src_var+="_app" ;;
		*) die "Unknown type: '${_type}'" ;;
	esac
	_src_var+="_locales"
	case "${_flag}" in
		'on') _src_var+="_on" ;;
		'off') _src_var+="_off" ;;
		*) die "Unknown flag: '${_flag}'" ;;
	esac

	eval "${_dst_var}=\"\$${_src_var}\""
}

l10n_for_each_global_locale_do() {
	local _l
	for _l in "${!L10N_LOCALES_MAP[@]}" ; do
		"${@}" ${_l} || die
	done
}

l10n_for_each_app_locale_do() {
	local _args=( "${@}" )
	_l10n_do() {
		local _ll
		for _ll in ${L10N_LOCALES_MAP["${1}"]} ; do
			"${_args[@]}" ${_ll} || die
		done
	}
	l10n_for_each_global_locale_do _l10n_do
	unset -f _l10n_do
}

# @FUNCTION: l10n_find_changes_in_dir
# @USAGE: <translations dir> <filename pre pattern> <filename post pattern>
# @DESCRIPTION:
# Ebuild maintenance helper function to find changes in package offered
# locales when doing a version bump. This could be added for example to
# src_prepare.
#
# Example: l10n_find_changes_in_dir "${S}/src/translations" "${PN}_" '.ts'
l10n_find_changes_in_dir() {
	debug-print-function ${FUNCNAME} "${@}"
	[[ ${#} != 3 ]] && die "Exactly 3 arguments are needed!"
	local _l _dir="${1}" _pre="${2}" _post="${3}"

	# _found = codes found in the directory
	# _known = codes specified in the ebuild
	# Note: using assoc array to allow instant lookup
	declare -A _found _known

	einfo "Looking in '${_dir}' for changes in locales ..."
	pushd "${_dir}" >/dev/null || die "Cannot access '${_dir}'"
	for _l in "${_pre}"*"${_post}" ; do
		_l="${_l#"${_pre}"}"
		_l="${_l%"${_post}"}"
		# continue if masked
		[[ -v _L10N_LOCALES_MASK["${_l}"] ]] && continue
		_found+=( ["${_l}"]= )
	done
	popd >/dev/null || die

	_l10n_add_to_known(){ _known+=( ["${1}"]= ); }
	local _locales=( "${_L10N_LOCALES[@]}" )
	l10n_for_each_app_locale_do _l10n_add_to_known
	unset -f _l10n_add_to_known

	local _added=() _removed=()
	# known but not found
	for _l in "${!_known[@]}" ; do
		[[ -v _found["${_l}"] ]] || _removed+=( "${_l}" )
	done
	# found but not known
	for _l in "${!_found[@]}" ; do
		[[ -v _known["${_l}"] ]] || _added+=( "${_l}" )
	done

	if [[ $(( ${#_added[@]} + ${#_removed[@]} )) > 0 ]] ; then
		elog "There are changes in locales!"
		if [[ ${#_added[@]} > 0 ]] ; then
			elog "Locales added: '${_added[*]}'"
		fi
		if [[ ${#_removed[@]} > 0 ]] ; then
			elog "Locales removed: '${_removed[*]}'"
		fi
	else
		einfo "No changes found"
	fi
}

_L10N_R1_ECLASS=1
fi
