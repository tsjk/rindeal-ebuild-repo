#!/bin/bash

read -r -d '' gawk_script <<'EOF'

BEGIN { header_not_found_yet=1; in_header=0; }

{
    if ( header_not_found_yet ) {
        if ( /^# / ) {
            header_not_found_yet=0;
            in_header=1;
            printf \
                "# Copyright 1999-%4.4d Gentoo Foundation\n" \
                "# Distributed under the terms of the GNU General Public License v2\n" \
                "# $Id$\n", strftime("%Y");
        }
    }
    if ( in_header ) {
        if ( /^[^#]/ || /^$/ ) {
            in_header=0;
            print;
        }
    } else {
        print;
    }
}

EOF

/usr/bin/gawk -i inplace -- "$gawk_script" "$1"
