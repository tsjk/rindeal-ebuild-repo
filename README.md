[![Build Status](https://travis-ci.org/rindeal/gentoo-overlay.svg?branch=master)](https://travis-ci.org/rindeal/gentoo-overlay)

In each category/package directory you should find _README_ file describing why it's included in this overlay.

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
location = /usr/local/portage/rindeal
sync-type = git
sync-uri = https://github.com/rindeal/gentoo-overlay.git
auto-sync = yes
```
