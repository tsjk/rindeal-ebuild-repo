#!/bin/bash -

[ -z "${PORTAGE_ROOT}" ] && { echo "PORTAGE_ROOT not set"; exit 1; }
mkdir -v -p "${PORTAGE_ROOT}"
[ -z "${PORTAGE_VER}" ] && { echo "PORTAGE_VER not set"; exit 1; }
: ${OVERLAY_NAME:=${TRAVIS_REPO_SLUG##*/}}

set -e


. "$(dirname "${BASH_SOURCE[0]}")/travis-functions.sh"

get_archive() {
    local url="$1" dir="$2"
    local tmpd="$(mktemp -d)" file="${url##*/}"

    pushd "${tmpd}"

    wget "$url" -O "${file}" || return 1
    mkdir -p "${dir}"
    tar xf "${file}" -C "${dir}" --strip-components=1 || return 2

    popd
    rm -r -f "${tmpd}"
}


## prepare env
## ------------
fold_start environment "Prepare environment"

tmp_dir="$(mktemp -d)"
gentoo_tree_dir="${PORTAGE_ROOT}/usr/portage"   && mkdir -v -p "${gentoo_tree_dir}"
portage_conf_dir="${PORTAGE_ROOT}/etc/portage"  && mkdir -v -p "${portage_conf_dir}"
DISTDIR="$(mktemp -d --suffix=-distdir)"

mkdir -v -p "${PORTAGE_ROOT}/usr/lib64"
ln -v -s lib64 "${PORTAGE_ROOT}/usr/lib"

fold_end environment


## install portage
## ----------------
fold_start portage.install "Install Portage"
{
    fold_start portage.install.pre
    {
        get_archive "https://github.com/gentoo/portage/archive/v${PORTAGE_VER}.tar.gz" "${tmp_dir}/portage-src"
        cd "${tmp_dir}/portage-src"
    }
    fold_end portage.install.pre

    fold_start portage.install.run
    {
        ./setup.py install -O2 --system-prefix="${PORTAGE_ROOT}/usr" --sysconfdir="${PORTAGE_ROOT}/etc"
    }
    fold_end portage.install.run

    fold_start portage.install.post
    {
        mkdir -v -p "${PORTAGE_ROOT}/usr/lib/portage/cnf/"
        cp -v 'cnf/metadata.dtd' "${DISTDIR}/"
    }
    fold_end portage.install.post
}
fold_end portage.install

## install gentoo tree
## --------------------
fold_start gentoo_tree "Install Gentoo Portage Tree"

get_archive 'https://github.com/gentoo-mirror/gentoo/archive/master.tar.gz' "${gentoo_tree_dir}"

fold_end gentoo_tree

## install portage configs
## ------------------------
fold_start configuration "Configure"

mkdir -v -p "${portage_conf_dir}/repos.conf"
cat > "${portage_conf_dir}/repos.conf/repos" << _EOF_
[DEFAULT]
main-repo = gentoo

[gentoo]
location = ${gentoo_tree_dir}

[${OVERLAY_NAME}]
location = ${TRAVIS_BUILD_DIR}
_EOF_

cat > "${portage_conf_dir}/make.conf" << _EOF_
DISTDIR="${DISTDIR}"
PKGDIR="$(mktemp -d --suffix=-pkdir)"
PORTAGE_TMPDIR="$(mktemp -d --suffix=-portage_tmpdir)"
RPMDIR="$(mktemp -d --suffix=-rpmdir)"
_EOF_

ln -v -s "${gentoo_tree_dir}/profiles/base" "${portage_conf_dir}/make.profile"

fold_end configuration

## cleanup
## --------
rm -rf "${tmp_dir}"
