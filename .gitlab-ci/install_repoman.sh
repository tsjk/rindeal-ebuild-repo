#!/bin/bash

set -e

cat <<-'_EOF_' >> /etc/portage/package.accepted_keywords
    # required by app-portage/repoman-2.3.0-r1::gentoo
    # required by repoman (argument)
    =dev-python/lxml-3.6.4 ~amd64
    # required by repoman (argument)
    =app-portage/repoman-2.3.0-r1 ~amd64
_EOF_

emerge --ask=n repoman
