#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <EBUILD>"
    exit 1
fi

EBUILD="$1"

new_ebuild=""

while IFS='' read -r l || [[ -n "$l" ]]; do
    if [[ "$l" =~ ^.*echo\ \"mk_add_options\ PROFILE_GEN_SCRIPT=.*$ ]]; then
        new_ebuild+="# $l
"
        new_ebuild+="$(cat <<'EOF'
		# PGO PATCH START
		echo "mk_add_options PROFILE_GEN_SCRIPT='EXTRA_TEST_ARGS=10 \\$(MAKE) -C \\$(MOZ_OBJDIR) pgo-profile-run'" >> "${S}/.mozconfig"
		# PGO PATCH END
EOF
)
"
    else
        new_ebuild+="$l
"
    fi
done < "$EBUILD"

new_ebuild2=""
in_src_prepare=0
while IFS='' read -r l || [[ -n "$l" ]]; do
    if [[ "$l" =~ src_prepare() ]]; then
        in_src_prepare=1
    fi

    if [[ $in_src_prepare -eq 1 ]] && [[ "$l" =~ ^}$ ]]; then
        new_ebuild2+="$(cat <<'EOF'
	
	# PGO PATCH START
	if use pgo; then
		printf "\n\n%s\n\t%s\n" 'pgo-profile-run:' '$(PYTHON) $(topsrcdir)/build/pgo/profileserver.py $(EXTRA_TEST_ARGS)' >> "${S}/Makefile.in"
		cp -r "${FILESDIR}/pgo/" "${S}/build/"
	fi
	# PGO PATCH END
}
EOF
)
"
        in_src_prepare=0
    else
        new_ebuild2+="$l
"
    fi
done <<< "$new_ebuild"

echo -E "$new_ebuild2" > "$EBUILD"
