Rindeal's Gentoo Overlay
==========================

### _The best overlay you have ever seen_

[![Build Status](https://img.shields.io/travis/rindeal/gentoo-overlay/master.svg?style=flat-square&label=repoman full)](https://travis-ci.org/rindeal/gentoo-overlay)
[![Dev Branch Build Status](https://img.shields.io/travis/rindeal/gentoo-overlay/dev.svg?style=flat-square&label=dev)](https://travis-ci.org/rindeal/gentoo-overlay)

Every package here has been carefully crafted to an unheard-of level of perfection.

Features that the vast majority of my ebuilds have in common:

 - **USE flags** are provided for every sensible configurable option
 - **Systemd** integration for every possible package (services, templates, timers, ...)
 - code in ebuilds is clean, commented and generally easy on the eyes
 - sane default configurations

Repository consists either from new packages/more up-to-date versions of official packages,
or rewritten ebuilds with fixed bugs and enhanced features.

In most package directories there is a _README_ file that says why is the package so much better than the official one.

User friendly list of packages is available [here][LISTING].

> _If you disagree with any of the statements above (or below), please [write your rant here][New issue]_

Quality Assurance
------------------

You should be able to switch completely to packages from my overlay without regrets.
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
## prefer my packages over official ones to improve UX and stability
#priority = 9999
```

#### 2. Sync

```sh
# Preferrably
eix-sync
# or if you need to
emerge --sync
```

### Layman

```sh
layman -o 'https://github.com/rindeal/gentoo-overlay/raw/master/repositories.xml' -a rindeal
# or more simply
layman -a rindeal
```


[protected branches]: https://help.github.com/articles/about-protected-branches/
[LISTING]: ./LISTING.md
[New issue]: https://github.com/rindeal/gentoo-overlay/issues/new
[Telegram]: https://desktop.telegram.org/
