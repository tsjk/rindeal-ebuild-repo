Rindeal's Gentoo Overlay
==========================

### _The best overlay you have ever seen_

[![Build Status](https://img.shields.io/travis/rindeal/gentoo-overlay/master.svg?style=flat-square&label=repoman full)](https://travis-ci.org/rindeal/gentoo-overlay)
[![Dev Branch Build Status](https://img.shields.io/travis/rindeal/gentoo-overlay/dev.svg?style=flat-square&label=dev)](https://travis-ci.org/rindeal/gentoo-overlay)

Every package here has been carefully crafted to an unheard-of level of perfection.

Features that the vast majority of my ebuilds have in common:

 - **USE flags** are provided for every sensible configurable option
 - **Systemd** integration for every possible package (services, templates, timers, ...)
 - beautiful, elegant and commented code in the ebuilds
 - sane default configurations

Repository consists either from new packages/more up-to-date versions of official packages,
or rewritten ebuilds with fixed bugs and enhanced features.

In most package directories there is a _README_ file that says why is the package so much better than the official one.

> _If you disagree with any of the statements above (or below), please [write your rant here][New issue]_

Highlights
-----------

### [Telegram]
My package is the only source-based package for _Telegram Desktop_ app, the others are just pre-built binaries.

### [JetBrains IntelliJ Platform](http://www.jetbrains.org/pages/viewpage.action?pageId=983889)
I've created a special eclass for _IntelliJ_ based IDEs, which allows to easily add and update any such IDE,
while still providing features like slotting and component unbundling (JRE, CMake, GDB, ...) using USE-flags.

### libtorrent-rasterbar + deluge (+ qBittorrent)
I'm providing a top-notch support and very nice ebuilds for these packages.
Official packages usually backport fixes and features from my ebuilds.

### ...

For a full package listing see [LISTING] \(don't hesitate, it's nice).


Quality Assurance
------------------

You should be able to switch completely to packages from my overlay without regrets.
To achieve this goal I'm using several safety guards:

- my brain of course
- _[Travis CI]_, which runs _[repoman]_ checks against every `git push`
- all points of _GitHub_'s feature called [protected branches], which means that all merges to _master_ have to be repoman-valid

This all, of course, doesn't prevent build failures, missing dependencies, etc. So, should you find
some issues, send me a PR (if you know how to fix it), or at least [file an issue][New issue].


How to install this overlay
----------------------------

### Manually (preferred)

#### 1. Add an entry to [`/etc/portage/repos.conf`](https://wiki.gentoo.org/wiki//etc/portage/repos.conf):

```ini
[rindeal]
## set this to any location you want
location = /var/lib/portage/rindeal
## prefer gentoo-mirror which includes metadata cache, but introduces a delay for hotfixes
sync-uri =  https://github.com/gentoo-mirror/rindeal.git
#sync-uri = https://github.com/rindeal/gentoo-overlay.git
sync-type = git
auto-sync = yes
## prefer my packages over official ones to improve stability and UX
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
[repoman]: https://wiki.gentoo.org/wiki/Repoman
[Travis CI]: https://travis-ci.org/
[LISTING]: ./LISTING.md
[New issue]: https://github.com/rindeal/gentoo-overlay/issues/new
[Telegram]: https://desktop.telegram.org/
