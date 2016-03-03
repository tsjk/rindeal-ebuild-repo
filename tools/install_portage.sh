#!/bin/bash - 

[ -z "${PORTAGE_ROOT}" ] && { echo "PORTAGE_ROOT not set"; exit 1; }
mkdir -p "${PORTAGE_ROOT}"
[ -z "${PORTAGE_VER}" ] && { echo "PORTAGE_VER not set"; exit 1; }

set -e


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
tmp_dir="$(mktemp -d)"
gentoo_tree_dir="${PORTAGE_ROOT}/usr/portage"
portage_conf_dir="${PORTAGE_ROOT}/etc/portage"
mkdir -p "${PORTAGE_ROOT}/usr/lib64" && ln -s lib64 "${PORTAGE_ROOT}/usr/lib"


## install portage
## ----------------
get_archive https://github.com/gentoo/portage/archive/v${PORTAGE_VER}.tar.gz "${tmp_dir}/portage-src"
cd "${tmp_dir}/portage-src"
./setup.py install -O2 --system-prefix="${PORTAGE_ROOT}/usr" --sysconfdir="${PORTAGE_ROOT}/etc"
mkdir -p "${PORTAGE_ROOT}/usr/lib/portage/cnf/"
cp cnf/metadata.dtd "${PORTAGE_ROOT}/usr/lib/portage/cnf/"


## install gentoo tree
## --------------------
get_archive https://github.com/gentoo-mirror/gentoo/archive/master.tar.gz "${gentoo_tree_dir}"


## install portage configs
## ------------------------
mkdir -p "${portage_conf_dir}/repos.conf"
cat > "${portage_conf_dir}/repos.conf/gentoo" << _EOF_
[DEFAULT]
main-repo = gentoo

[gentoo]
location = ${gentoo_tree_dir}
_EOF_

cat > "${portage_conf_dir}/make.conf" << _EOF_
DISTDIR="$(mktemp -d)"
PKGDIR="$(mktemp -d)"
PORTAGE_TMPDIR="$(mktemp -d)"
RPMDIR="$(mktemp -d)"
_EOF_

ln -s "${gentoo_tree_dir}/profiles/base" "${portage_conf_dir}/make.profile"


## cleanup
## --------
rm -rf "${tmp_dir}"

