#!/bin/bash

set -e
set -x

cat <<-'_EOF_' >> /etc/portage/package.accept_keywords
    # required by app-portage/repoman-2.3.0-r1::gentoo
    # required by repoman (argument)
    =dev-python/lxml-3.6.4 ~amd64
    # required by =sys-apps/portage-2.3.0 (argument)
    =sys-apps/portage-2.3.0 ~amd64
    # required by repoman (argument)
    =app-portage/repoman-2.3.0-r1 ~amd64
_EOF_

eselect profile set default/linux/amd64/13.0/systemd

emerge --ask=n repoman
