Rindeal's Gentoo Overlay
==========================
[![Build Status](https://img.shields.io/travis/rindeal/gentoo-overlay/master.svg?style=flat-square&label=repoman full -d)](https://travis-ci.org/rindeal/gentoo-overlay)

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
