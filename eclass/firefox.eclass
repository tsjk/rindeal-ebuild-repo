# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: firefox.eclass
# @MAINTAINER:
# Jan Chren (rindeal) <dev.rindeal+gentoo-overlay@gmail.com>
# @BLURB: Support eclass for Firefox
# @DESCRIPTION:

if [ -z "${_FIREFOX_ECLASS}" ] ; then

case "${EAPI:-0}" in
	6) ;;
	*) die "Unsupported EAPI='${EAPI}' for '${ECLASS}'" ;;
esac

__class_end() {
	local __d__ __o__ __f__
	while read __d__  __o__ __f__ ; do
		[[ "${__f__}" != "$self::"* ]] && continue
		__f__="$(declare -f "$__f__")"
		eval "${__f__//\$self/${self}}"
	done < <(declare -F)
	unset self
}

namespace=firefox

firefox::use_cmt() {
	echo "USE=$(usex $1 '' '!')$1"
}

# BEGIN firefox::mozconfig
# --------------------------------------------------------------------------------------------------
self=firefox::mozconfig

firefox::mozconfig::stmt() {
	local stmt="$1" cmt="$2"
	shift 2
	[[ $# -gt 0 ]] || die "${FUNCNAME} called with no flags. Comment: '${cmt}'"
	[ ! -v MOZCONFIG ] && die "MOZCONFIG not defined"

	local x
	for x in "${@}" ; do
		# fix payloads with spaces
		if [[ "${x}" == *'='* ]] ; then
			local key="${x%%=*}" val="${x#*=}"
			if [[ ! "${val:0:1}" =~ "('|\")" ]] ; then
				x="${key}='${val}'"
			fi
		fi

		printf "%s %s # %s\n" \
			"${stmt}" "${x}" "${cmt}" >>"${MOZCONFIG}" || die
	done
}

firefox::mozconfig::add_options() {
	$self::stmt 'ac_add_options' "$@"
}

firefox::mozconfig::use_enable() {
	$self::add_options "$(firefox::use_cmt $1)" $(use_enable "$@")
}

firefox::mozconfig::use_with() {
	$self::add_options "$(firefox::use_cmt $1)" $(use_with "$@")
}

# TODO: remove this func
firefox::mozconfig::use_extension() {
	$self::add_options "$(firefox::use_cmt $1)" $(usex $1 --enable-extensions={,-}${2})
}

firefox::mozconfig::use_set() {
	local use="$1"
	local var="${2:-"MOZ_${use^^}"}"
	$self::stmt \
		"$(usex ${use} 'export' 'unset')" \
		"$(firefox::use_cmt ${use})" \
		"${var}$(usex ${use} '=1' '')"
}

firefox::mozconfig::init() {
	local econf=(
		"${CBUILD:+"--build=${CBUILD}"}"
		--datadir="${EPREFIX}"/usr/share
		--host=${CHOST}
		--infodir="${EPREFIX}"/usr/share/info
		--localstatedir="${EPREFIX}"/var/lib
		--prefix="${EPREFIX}"/usr
		--mandir="${EPREFIX}"/usr/share/man
		--sysconfdir="${EPREFIX}"/etc
		${CTARGET:+"--target=${CTARGET}"}
		--disable-dependency-tracking

		## extensions
		--libdir="${EPREFIX}/usr/$(get_libdir)"
	)
	$self::add_options 'econf' "${econf[@]}"

	$self::add_options '' --enable-application=browser
}

firefox::mozconfig::keyfiles() {
	firefox::mozconfig::_keyfile() {
		local name="$1" ; shift
		local file="${T}/.${name}"
		echo -n "$@" >"${file}" || die
		$self::add_options "${name}" --with-${name}-keyfile="${file}"
	}

	# Google API keys (see http://www.chromium.org/developers/how-tos/api-keys)
	# Note: These are for Gentoo Linux use ONLY. For your own distribution, please
	# get your own set of keys.
	# safebrowsing/geolocation
	$self::_keyfile 'google-api'		'AIzaSyDEAOvatFo0eTgsV_ZlEzx0ObmepsMzfAc'

	# FIXME: these are from Arch

	# for Loop/Hello service (https://wiki.mozilla.org/Loop/OAuth_Setup)
	$self::_keyfile 'google-oauth-api'	'413772536636.apps.googleusercontent.com 0ZChLK6AxeA3Isu96MkwqDR4'

	# for geolocation/geoip
	# pref("geo.wifi.uri", "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%");
	$self::_keyfile 'mozilla-api'		'16674381-f021-49de-8622-3021c5942aff'

	# --with-bing-api-keyfile		# windows only
	# --with-adjust-sdk-keyfile		# mozilla tracking
	# --with-gcm-senderid-keyfile	# android only
}

# FIXME: make this func unnecessary
# Resolve multiple --enable-extensions down to one
firefox::mozconfig::fix_enable-extensions() {
	[ ! -f "${MOZCONFIG}" ] && die
	local exts=(
		$(sed -n -r 's|^ac_add_options *--enable-extensions=([^ ]*).*|\1|p' -- "${MOZCONFIG}")
	)
	if [ ${#exts[@]} -gt 1 ] ; then
		local joint="$(IFS=,; echo "${exts[*]}")"
		echo "mozconfig: merging multiple extensions: '${joint}"
		sed -e '/^ac_add_options *--enable-extensions/d' \
			-i -- "${MOZCONFIG}" || die
		$mozconfig::add_options "extensions" --enable-extensions="${joint}"
	fi
}

# Display a table describing all configuration options paired with reasons.
# It also serves as a dumb config checker.
firefox::mozconfig::pretty_print() {
	eshopts_push -s extglob

	echo
	printf -- '=%.0s' {1..100}	; echo
	printf -- ' %.0s' {1..20}	; echo "Building ${PF} with the following configuration"
	printf -- '-%.0s' {1..100}	; echo

	local format="%-20s | %-50s # %s\n"
	printf "${format}" \
		' action' ' value' ' comment'
	printf "${format}" \
		"$(printf -- '-%.0s' {1..20})" "$(printf -- '-%.0s' {1..50})" "$(printf -- '-%.0s' {1..20})"

	local line
	while read line ; do
		eval set -- "${line/\#/@}"
		local action="$1" val="$2" at="$3"
		local cmt=
		[[ "${line}" == *\#* ]] && cmt="${line##*#*( )}"
		: ${cmt:="default"}

		if [ -n "${at}" ] && [ "${at}" != '@' ] ; then
			die "error reading mozconfig: '${action}' '${val}' '${at}' '${cmt}'"
		fi

		printf "${format}" \
			"${action}" "${val}" "${cmt}" || die
	done < <( grep '^[^# ]' "${MOZCONFIG}" | sort )
	printf -- '=%.0s' {1..100} ; echo
	echo

	eshopts_pop
}

firefox::mozconfig::final() {
	firefox::src_configure::keyfiles
	$self::fix_enable-extensions
	$self::pretty_print
}

__class_end
# END firefox::mozconfig
# --------------------------------------------------------------------------------------------------

# BEGIN firefox::prefs
# --------------------------------------------------------------------------------------------------
self=firefox::prefs

firefox::prefs::add() {
	local cmt="$1" name="$2" val="$3"

	if ! [[ "${val}" =~ ^(-?[0-9]+|true|false)$ ]] ; then
		val="\"${val}\""
	fi

	printf 'pref("%s", %s); // %s\n' \
		"${name}" "${val}" "${cmt}" >>"${DEFAULT_PREFS_JS}" || die
}

__class_end
# END firefox::prefs
# --------------------------------------------------------------------------------------------------

# BEGIN firefox::src_configure
# --------------------------------------------------------------------------------------------------
self=firefox::src_configure

__class_end
# END firefox::src_configure
# --------------------------------------------------------------------------------------------------

unset namespace

_FIREFOX_ECLASS=1
fi
