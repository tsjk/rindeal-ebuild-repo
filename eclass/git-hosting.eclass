# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: git-hosting.eclass
# @MAINTAINER:
# Jan Chren (rindeal) <dev.rindeal+gentoo@gmail.com>
# @BLURB: Support eclass for packages hosted on online git hosting services like Github

if [ -z "${_GH_ECLASS}" ] ; then

case "${EAPI:-0}" in
	5|6) ;;
	*) die "Unsupported EAPI='${EAPI}' for '${ECLASS}'" ;;
esac

##
# @ECLASS-VARIABLE: GH_URI
# @DEFAULT_UNSET
# @DESCRIPTION:
# String in the format:
#
#      <provider>[/<user_name>[/<repository_name>]]
#
# Default <user_name> and <repository_name> is ${PN}.
##
[[ -z "${GH_URI}" ]] && die "GH_URI must be set to a non-empty value"

# use an array to split the string to '/' delimited parts
_GH_URI_A=( ${GH_URI//\// } )

##
# @ECLASS-VARIABLE: GH_PROVIDER
# @READONLY
# @DEFAULT_UNSET
# @DESCRIPTION:
# Contains the first part of GH_URI - the git hosting provider.
# Currently one of 'github', 'gitlab', 'bitbucket'.
##
GH_PROVIDER="${_GH_URI_A[0]}"

##
# @ECLASS-VARIABLE: GH_USER
# @READONLY
# @DEFAULT: ${PN}
# @DESCRIPTION:
# Contains the second part of GH_URI - the username/orgname/groupname.
##
GH_USER="${_GH_URI_A[1]:-"${PN}"}"

##
# @ECLASS-VARIABLE: GH_REPO
# @READONLY
# @DEFAULT: ${PN}
# @DESCRIPTION:
# Contains the third part of GH_URI - the repository name.
##
GH_REPO="${_GH_URI_A[2]:-"${PN}"}"

readonly GH_PROVIDER GH_USER GH_REPO
unset _GH_URI_A

##
# @ECLASS-VARIABLE: GH_FETCH_TYPE
# @DEFAULT: 'snapshot', for versions containing '9999' defaults to 'live'
# @DESCRIPTION:
# Defines if fetched from git ("live") or archive ("snapshot") or eclass
# shouldn't handle fetching at all ("manual").
##
if [[ -z "${GH_FETCH_TYPE}" ]] ; then
	if [[ "${PV}" == *9999* ]] ; then
		GH_FETCH_TYPE='live'
	else
		GH_FETCH_TYPE='snapshot'
	fi
fi
readonly GH_FETCH_TYPE

##
# @ECLASS-VARIABLE: GH_REF
# @DEFAULT: for 'snapshot', "${PV}"
# @DESCRIPTION:
# Tag/commit/git_ref (except branches) that is fetched from git hosting provider.
##
if [[ -z "${GH_REF}" ]] ; then
	case "${GH_FETCH_TYPE}" in
		'snapshot')
			# a research conducted on April 2016 among the first 700 repos with >10000 stars on GitHub shows:
			# - no tags: 158
			# - `v` prefix: 350
			# - no prefix: 192
			GH_REF="${PV}" ;;
		'live' | 'manual') : ;;
		*) die "Unsupported fetch type: '${GH_FETCH_TYPE}'" ;;
	esac
fi
readonly GH_REF

##
# @ECLASS-VARIABLE: GH_DISTFILE
# @DEFAULT: ${P}-${GH_PROVIDER}
# @DESCRIPTION:
# Name of the distfile (without any extensions).
##
: "${GH_DISTFILE:="${P}-${GH_PROVIDER}"}"
readonly GH_DISTFILE


case "${GH_PROVIDER}" in
	'bitbucket')
		_GH_DOMAIN='bitbucket.org' ;;
	'github')
		_GH_DOMAIN='github.com' ;;
	'gitlab')
		_GH_DOMAIN='gitlab.com' ;;
	*) die "Unsupported provider '${GH_PROVIDER}'" ;;
esac


##
# @ECLASS-VARIABLE: GH_BASE_URI
# @READONLY
# @DEFAULT: "https://${_GH_DOMAIN}/${GH_USER}/${GH_REPO}"
# @DESCRIPTION:
# Base uri of the repo
##
declare -g -r GH_BASE_URI="https://${_GH_DOMAIN}/${GH_USER}/${GH_REPO}"


# set SRC_URI only for 'snapshot' GH_FETCH_TYPE
declare -g -- _GH_SNAPSHOT_SRC_URI=''
if [[ "${GH_FETCH_TYPE}" == 'snapshot' ]] ; then
	case "${GH_PROVIDER}" in
		'bitbucket')
			_GH_SNAPSHOT_EXT=".tar.bz2"
			_GH_SNAPSHOT_URI_PATH="get/${GH_REF}${_GH_SNAPSHOT_EXT}"
			;;
		'github')
			_GH_SNAPSHOT_EXT=".tar.gz"
			_GH_SNAPSHOT_URI_PATH="archive/${GH_REF}${_GH_SNAPSHOT_EXT}"
			;;
		'gitlab')
			_GH_SNAPSHOT_EXT=".tar.gz"
			_GH_SNAPSHOT_URI_PATH="repository/archive${_GH_SNAPSHOT_EXT}?ref=${GH_REF}"
			;;
		*) die "Unsupported provider '${GH_PROVIDER}'" ;;
	esac

	_GH_SNAPSHOT_FILENAME="${GH_DISTFILE}${_GH_SNAPSHOT_EXT}"
	_GH_SNAPSHOT_SRC_URI="${GH_BASE_URI}/${_GH_SNAPSHOT_URI_PATH} -> ${_GH_SNAPSHOT_FILENAME}"
	SRC_URI="${_GH_SNAPSHOT_SRC_URI}"
	readonly _GH_SNAPSHOT_FILENAME _GH_SNAPSHOT_SRC_URI
fi

if [[ -z "${EGIT_REPO_URI}" ]] ; then
	EGIT_REPO_URI="
		${GH_BASE_URI}.git
		git@${_GH_DOMAIN}:${GH_USER}/${GH_REPO}.git"
fi


case "${GH_FETCH_TYPE}" in
	'live')
		[[ -n "${GH_REF}" && -z "${EGIT_COMMIT}" ]] && \
			EGIT_COMMIT="${GH_REF}"
		[[ -z "${EGIT_CLONE_TYPE}" ]] && \
			EGIT_CLONE_TYPE="shallow"

		inherit git-r3
		;;
	'snapshot') : ;;
	'manual') : ;;
	*) die "Unsupported fetch type: '${GH_FETCH_TYPE}'" ;;
esac


: "${HOMEPAGE:="${GH_BASE_URI}"}"

# prefer their CDN over Gentoo mirrors
RESTRICT="${RESTRICT} primaryuri"


# debug-print summary
if [[ -n "${EBUILD_PHASE_FUNC}" && "${EBUILD_PHASE_FUNC}" == 'pkg_setup' ]] ; then
	debug-print "${ECLASS}: -- vardump --"
	for _v in $(compgen -A variable) ; do
		if [[ "${_v}" == "GH_"* || "${_v}" == "EGIT_"* ]] ; then
			debug-print "${ECLASS}: ${_v}='${!_v}'"
		fi
	done
	debug-print "${ECLASS}: ----"
	unset _v
fi


EXPORT_FUNCTIONS src_unpack


##
# @FUNCTION: git-hosting_src_unpack
# @DESCRIPTION:
# Handles unpacking of special source files, like git snapshots, live git repos, ...
#
# Please note that if GH_FETCH_TYPE=~(live|snapshot) this function won't unpack files from SRC_URI
# other than those it added itself, additionally, upon execution it filters them out of '${A}' variable, so
# that you can than loop through '${A}' safely and unpack the rest yourself or just call default().
##
git-hosting_src_unpack() {
	debug-print-function "${FUNCNAME}"

	case "${GH_FETCH_TYPE}" in
		'live') git-r3_src_unpack ;;
		'snapshot')
			# do not use '${S}' for 'unpack_to' as user might overwrite 'S' leading to a wrong behaviour
			local unpack_from="${DISTDIR}/${_GH_SNAPSHOT_FILENAME}" unpack_to="${WORKDIR}/${P}"

			## extract snapshot to 'S'
			printf ">>> Unpacking '%s' to '%s'\n" "${unpack_from##*/}" "${unpack_to}"
			mkdir -p "${unpack_to}" || die "Failed to create S='${unpack_to}' directory"
			tar --extract \
				--strip-components=1 \
				--file="${unpack_from}" --directory="${unpack_to}" \
				|| die "Failed to extract '${unpack_from}' archive"

			## filter 'unpack_from' from 'A'
			local f new_a_a=()
			for f in ${A} ; do
				if [[ "${f}" != "${unpack_from##*/}" ]] ; then
					new_a_a+=( "${f}" )
				fi
			done
			A="${new_a_a[@]}"
			;;
		'manual') default ;;
		*) die ;;
	esac
}


_GH_ECLASS=1
fi
