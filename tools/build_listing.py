#!/usr/bin/env python3
# Copyright 2016 Jan Chren (rindeal) <dev.rindeal@gmail.com>
# Distributed under the terms of the GNU General Public License v2

import glob
import os
from collections import defaultdict

root_dir = os.path.realpath(os.path.dirname(os.path.realpath(__file__)) + './../')
os.chdir(root_dir)
os.environ["PORTDIR_OVERLAY"] = "./"

cats = defaultdict(set)

for f in glob.iglob('*/*/*.ebuild'):
    parts = f.split('/')
    cats[parts[0]].add(parts[1])
for c in cats:
    cats[c] = sorted(cats[c])

print('<a id="top"></a>')
print()
print('Category | Packages')
print('--- | ---')

for c in sorted(cats):
    print('<a id="cat-{0}"></a>**{0}** | '.format(c), end='')
    first = True
    for p in cats[c]:
        if first:
            first = False
            prefix = ''
        else:
            prefix = ', '
        print('{2}[{1}](#{0}-{1})'.format(c, p, prefix), end='')
    print()

print('\n---\n')

import portage
portage_db = portage.db[portage.root]["porttree"].dbapi

print('Package | Description | :house: | :back:')
print('--- | --- | --- | ---')

for c in sorted(cats):
    for p in cats[c]:
        pkg = portage_db.xmatch("match-all", '{0}/{1}::rindeal'.format(c,p))[0]
        desc, home = portage_db.aux_get(pkg, ['DESCRIPTION', 'HOMEPAGE'])
        home = home.split()[0] # get only the first homepage
        print('<a id="{0}-{1}"></a><a href="./{0}/{1}"><sub><sup>{0}/</sup></sub><strong>{1}</strong></a> | {2} | [:house:]({3}) | [:back:](#cat-{0})'.format(c, p, desc, home))

# insert vertical space so that clicking on a reference scrolls down nicely
for i in range(1, 20):
    print()
    print('&nbsp;')
