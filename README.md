Rindeal's Gentoo Overlay
==========================
[![Build Status](https://img.shields.io/travis/rindeal/gentoo-overlay/master.svg?style=flat-square&label=repoman full)](https://travis-ci.org/rindeal/gentoo-overlay)

Repository consists mostly of packages I haven't found anywhere else, more up-to-date versions of official packages, or ebuilds with features enhanced to my liking.
In each category/package directory you should find a _README_ file describing the exact reason of its inclusion in this repository.

For package listing see [LISTING.md](./LISTING.md).

## How to install this overlay
### Layman
```
root # layman -o https://github.com/rindeal/gentoo-overlay/raw/master/repositories.xml -a rindeal
```

### Manually
Add an entry to `/etc/portage/repos.conf`:
```ini
[rindeal]
# set this to any location you want
# location = /usr/local/portage/rindeal
sync-type = git
sync-uri = https://github.com/rindeal/gentoo-overlay.git
# or if you don't mind a small delay, you might use gentoo-mirror which includes metadata cache
#sync-uri =  https://github.com/gentoo-mirror/rindeal.git
auto-sync = yes
```

## Stability

I am trying to maintain high quality and stable ebuilds here.
To achieve this goal I'm using several safety guards:

- [_Travis CI_](https://travis-ci.org/), which runs [_repoman_](https://wiki.gentoo.org/wiki/Repoman) checks against every `git push`
- all points of _GitHub_'s feature called [protected branches](https://help.github.com/articles/about-protected-branches/), which means that all merges to _master_ have to be repoman-valid

This all, of course, doesn't prevent build failures, missing dependencies, etc. So, should you find some issues, send me a PR (if you know how to fix it), or at least [fill an issue](https://github.com/rindeal/gentoo-overlay/issues/new).

Also, I regularly do rounds of pushes from here to the main Gentoo tree for packages which are mature enough and suitable for being upstreamed there.
