#!/bin/bash

wget -O - -q https://get.geo.opera.com/pub/opera/desktop/ | \
awk '
    /href="[0-9]+\./ {
        match($0, /href="([0-9\.]+)/, matches)
        ver=matches[1]
        split(ver, components, ".")
        cur_best_major = BEST_MAJORS[components[1]]
        if ( ! cur_best_major ) {
            cur_best_major = "0.0.0.0"
        }
        split(cur_best_major, cur_best_maj_comp, ".")
        for ( i =  1 ; i <= 4 ; i++ ) {
            if (components[i] > cur_best_maj_comp[i]) {
                BEST_MAJORS[components[1]] = ver
                break
            }
        }
    }

    END {
        for ( maj in BEST_MAJORS ) {
            print BEST_MAJORS[maj]
        }
    }
'
