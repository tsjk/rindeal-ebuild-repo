#!/bin/bash - 

[ -z "${PORTAGE_ROOT}" ] && { echo "PORTAGE_ROOT not set"; exit 1; }
[ -z "${PORTAGE_VER}" ] && { echo "PORTAGE_VER not set"; exit 1; }

set -e

mkdir -p "${PORTAGE_ROOT}"

tmp_dir="$(mktemp -d)"


cd "${tmp_dir}"
wget https://github.com/gentoo/portage/archive/v${PORTAGE_VER}.tar.gz -O portage.tar.gz
mkdir portage-src
tar xf portage.tar.gz -C portage-src --strip-components=1 && rm portage.tar.gz
cd portage-src
./setup.py install --root="${PORTAGE_ROOT}"
mkdir -p "${PORTAGE_ROOT}/usr/lib/portage/cnf/"
cp cnf/metadata.dtd "${PORTAGE_ROOT}/usr/lib/portage/cnf/"


cd "${tmp_dir}"
wget https://github.com/gentoo-mirror/gentoo/archive/master.tar.gz -O gentoo.tar.gz
mkdir -p "${PORTAGE_ROOT}/usr/portage"
tar xf gentoo.tar.gz -C "${PORTAGE_ROOT}/usr/portage" --strip-components=1 && rm gentoo.tar.gz

mkdir -p "${PORTAGE_ROOT}/etc/portage/repos.conf"
cat > "${PORTAGE_ROOT}/etc/portage/repos.conf/gentoo" << _EOF_
[DEFAULT]
main-repo = gentoo

[gentoo]
location = ${PORTAGE_ROOT}/usr/portage
_EOF_

ln -s "${PORTAGE_ROOT}/usr/portage/profiles/base" "${PORTAGE_ROOT}/etc/portage/make.profile"


rm -rf "${tmp_dir}"

