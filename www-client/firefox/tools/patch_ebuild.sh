#!/bin/sh

if [ -z "$1" ]; then
    echo "Usage: $0 <EBUILD>"
    exit 1
fi

EBUILD="$1"

sed -i -r \
    -e 's@^.*echo "mk_add_options PROFILE_GEN_SCRIPT=.*$@\t\t# !PATCHED LINE BELOW!\n\t\techo "mk_add_options PROFILE_GEN_SCRIPT='\''EXTRA_TEST_ARGS=10 \\$(MAKE) -C \\$(MOZ_OBJDIR) pgo-profile-run'\''" >> "${S}"/.mozconfig \n@' \
    -e '/src_prepare\(\)/,/^}$/{
            s@^}$@\n\t# !PATCHED LINE BELOW!\n\tif use pgo; then\n\t\tprintf "\\n\\n%s\\n\\t%s\\n" '\''pgo-profile-run:'\'' '\''$(PYTHON) $(topsrcdir)/build/pgo/profileserver.py $(EXTRA_TEST_ARGS)'\'' >> "${S}/Makefile.in"\n\t\tcp -r "$FILESDIR/pgo/" "$S/build/"\n\tfi\n}\n@
        }' \
    "$EBUILD"

