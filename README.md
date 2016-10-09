Rindeal's Gentoo Overlay
==========================

### _The best overlay you have ever seen_

[![Build Status](https://img.shields.io/travis/rindeal/gentoo-overlay/master.svg?style=flat-square&label=repoman full)](https://travis-ci.org/rindeal/gentoo-overlay)
[![Dev Branch Build Status](https://img.shields.io/travis/rindeal/gentoo-overlay/dev.svg?style=flat-square&label=dev)](https://travis-ci.org/rindeal/gentoo-overlay)

Every package here has been carefully crafted to an unheard-of level of perfection.

Features that the vast majority of my ebuilds have in common:

 - code in ebuilds is clean, elegant, uncluttered, commented and generally easy on the eyes, thus making packages maintainable and easily updatable
 - **USE flags** are provided for almost any configurable option
 - full **Systemd** integration (services, templates, timers, ...), no OpenRC/cron support
 - sane default configurations (default USE-flags, config files, ...)
 - **locales** support (`nls`/`l10n_*` USE-flags)
 - **amd64/arm** architectures only, which removes clutter introduced for exotic arches
 - only the **native ABI** is supported, again to reduce the clutter

In most package directories there is a _README_ file that says why is the package superior to any other out there including the "official" one.

> _If you find a package superior to mine, please [report it here][New issue]_.

User friendly list of packages is available [here][LISTING].
I highly encourage you to browse through the list as the chances are high for you to discover some great new software.


Quality Assurance
------------------

You should be able to use any package from my overlay without regrets.
To achieve this goal I'm using several safety guards:

- my brain of course
- _[Travis CI](https://travis-ci.org/)_, which runs:
    - _[repoman](https://wiki.gentoo.org/wiki/Repoman)_ checks
    - _[shellcheck](https://www.shellcheck.net/)_ checks
    - custom checks
- all points of _GitHub_'s feature called [protected branches], which means that all merges to _master_ have to pass CI tests

This all, of course, doesn't prevent build failures, missing dependencies, etc. So, should you find
some issues, send me a PR (if you know how to fix it), or at least [file an issue][New issue].


How to install this overlay
----------------------------

### Manually (preferred)

#### 1. Add an entry to [`/etc/portage/repos.conf`](https://wiki.gentoo.org/wiki//etc/portage/repos.conf):

```ini
[rindeal]
## set this to any location you want
location = /var/cache/portage/repos/rindeal
## prefer gentoo-mirror which includes metadata cache, but introduces a delay for hotfixes
sync-uri =  https://github.com/gentoo-mirror/rindeal.git
#sync-uri = https://github.com/rindeal/gentoo-overlay.git
sync-type = git
auto-sync = yes
## prefer my packages over the official ones to improve UX and stability
#priority = 9999
```

#### 2. Sync

```sh
# Preferrably
eix-sync
# or if you need to
emerge --sync
```

### Automatically with Layman

```sh
layman -o 'https://github.com/rindeal/gentoo-overlay/raw/master/repositories.xml' -a rindeal
# or more simply
layman -a rindeal
```


[protected branches]: https://help.github.com/articles/about-protected-branches/
[LISTING]: ./LISTING.md
[New issue]: https://github.com/rindeal/gentoo-overlay/issues/new
[Telegram]: https://desktop.telegram.org/
