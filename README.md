Rindeal's Gentoo Overlay
==========================
[![Build Status](https://travis-ci.org/rindeal/gentoo-overlay.svg?branch=master)](https://travis-ci.org/rindeal/gentoo-overlay)

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
auto-sync = yes
```
