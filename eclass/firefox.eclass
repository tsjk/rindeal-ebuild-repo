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

firefox::mozconfig::stmt() {
	local stmt="$1" cmt="$2"
	shift 2
	[[ $# -gt 0 ]] || die "${FUNCNAME} called with no flags. Comment: '${cmt}'"
	[ ! - v MOZCONFIG ] && die "MOZCONFIG not defined"

	local x
	for x in "${@}" ; do
		printf "%s %s # %s\n" \
			"${stmt}" "${x}" "${cmt}" >>"${MOZCONFIG}" || die
	done
}

firefox::mozconfig_options() {
	firefox::mozconfig::stmt 'ac_add_options' "$@"
}

firefox::use_cmt() {
	echo "USE=$(usex $1 '' '!')$1"
}

firefox::mozconfig_use_enable() {
	firefox::mozconfig_options "$(firefox::use_cmt $1)" $(use_enable "$@")
}

firefox::mozconfig_use_with() {
	firefox::mozconfig_options "$(firefox::use_cmt $1)" $(use_with "$@")
}

# TODO: remove this func
firefox::mozconfig_use_extension() {
	firefox::mozconfig_options "$(firefox::use_cmt $1)" $(usex $1 --enable-extensions={,-}${2})
}

firefox::mozconfig_use_set() {
	local use="$1"
	local var="${2:-"MOZ_${use^^}"}"
	firefox::mozconfig::stmt \
		"$(usex ${use} 'export' 'unset')" \
		"$(firefox::use_cmt ${use})" \
		"${var}$(usex ${use} '=1' '')"
}

firefox::mozconfig_init() {
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
	)
	firefox::mozconfig_options 'econf' "${econf[@]}"
}

# Display a table describing all configuration options paired with reasons.
# It also serves as a dumb config checker.
firefox::mozconfig_pretty_print() {
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

firefox::default_pref() {
	local name="$1" val="$2" cmt="$3"

	if ! [[ "${val}" =~ ^(-?[0-9]+|true|false)$ ]] ; then
		val="\""${val}\"""
	fi

	printf 'pref("%s", %s); // %s' \
		"${name}" "${val}" "${cmt}" >>"${DEFAULT_PREFS_JS}" || die
}

firefox::src_configure-keyfiles() {
	firefox::keyfile() {
		local name="$1" ; shift
		local file="${T}/.${name}"
		echo -n "$@" >"${file}" || die
		firefox::mozconfig_options "${name}" --with-${name}-keyfile="'${file}'"
	}

	# Google API keys (see http://www.chromium.org/developers/how-tos/api-keys)
	# Note: These are for Gentoo Linux use ONLY. For your own distribution, please
	# get your own set of keys.
	firefox::keyfile 'google-api'			'AIzaSyDEAOvatFo0eTgsV_ZlEzx0ObmepsMzfAc'

	# FIXME: these are from Arch

	# for Loop/Hello service (https://wiki.mozilla.org/Loop/OAuth_Setup)
	firefox::keyfile 'google-oauth-api'	'413772536636.apps.googleusercontent.com 0ZChLK6AxeA3Isu96MkwqDR4'

	# for geolocation
	# pref("geo.wifi.uri", "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%");
	firefox::keyfile 'mozilla-api'		'16674381-f021-49de-8622-3021c5942aff'

	# --with-bing-api-keyfile		# windows only
	# --with-adjust-sdk-keyfile		# mozilla tracking
	# --with-gcm-senderid-keyfile	# android only
}

_FIREFOX_ECLASS=1
fi
