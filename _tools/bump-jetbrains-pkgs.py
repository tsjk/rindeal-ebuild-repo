#!/usr/bin/env python3

import requests
import portage
import os
import traceback
import glob
from terminaltables import AsciiTable
from multiprocessing import Pool, Process, Lock
import subprocess


DEBUG=0
if 'DEBUG' in os.environ:
    DEBUG = os.environ['DEBUG']

PORTDIR_OVERLAY=os.path.realpath(os.path.dirname(os.path.realpath(__file__)) + "/../")
os.chdir(PORTDIR_OVERLAY)
os.environ["PORTDIR_OVERLAY"] = PORTDIR_OVERLAY


# retrieves the latest versions for specified product codes
def get_version( codes ):
    payload = {
        'code': ','.join(codes),
        'latest': 'false',
        'type': 'release'
    }
    r = requests.get('https://data.services.jetbrains.com/products/releases', params=payload)
    json=r.json()
    # [code][slot/latest]
    versions = {}
    for c in codes:
        versions[c] = {}
        all_v = json[c]

        # the first one is always the latest
        versions[c]['latest'] = all_v[0]['version']

        for v in all_v:
            slot = v['majorVersion']
            if not slot in versions[c]:
                versions[c][slot] = v['version']

    return versions

# format: `package_name: product_code`
codes={
    'clion': 'CL',
    'datagrip': 'DG',
    'idea': 'IIU',
    'idea-community': 'IIC',
    'phpstorm': 'PS',
    'pycharm': 'PCP',
    'pycharm-community': 'PCC',
    'rubymine': 'RM',
    'webstorm': 'WS',
}

versions = get_version(codes.values())

pdb = portage.db[portage.root]["porttree"].dbapi

table=[ [ 'Category', 'Package', 'Slot', 'Current version', 'New version' ] ]

for pn, code in sorted(codes.items()):
    # find category by globbing in this repo
    cat = glob.glob("*/{0}/{0}*.ebuild".format(pn))[0].split("/")[0]

    # find the newest version for each slot
    slots = {}
    all_versions = pdb.xmatch('match-visible', '{}/{}::rindeal'.format(cat, pn))
    for v in all_versions:
        slot = pdb.aux_get(v, ["SLOT"])[0]
        # add if not yet present
        if not slot in slots:
            slots[slot] = v
            continue
        # update slot if newer version was found
        if portage.vercmp(slots[slot], v) < 0:
            slots[slot] = v

    # now compare current and server versions for each slot
    for slot in slots:
        pkg = slots[slot]

        old_ver = portage.pkgsplit(pkg)[1]
        new_ver = versions[code][slot]

        if portage.vercmp(old_ver, new_ver) < 0:
            table.append([cat, pn, slot, old_ver, new_ver])

    # not look for the newest version outside of any slots
    pkg = pdb.xmatch('bestmatch-visible', '{}/{}::rindeal'.format(cat, pn))
    old_ver = portage.pkgsplit(pkg)[1]
    new_ver = versions[code]['latest']
    if portage.vercmp(old_ver, new_ver) < 0:
        # check if duplicate
        c,p,s,o,n = table[-1]
        if c == cat and p == pn and n == new_ver:
            continue
        table.append([cat, pn, 'latest', old_ver, new_ver])

# now print the table
print(AsciiTable(table).table)
# and prompt the user for an action
y = input("Press 'y' to proceed with the update\n")
if y != "y":
    print("You pressed '{}', bailing...".format(y))
    exit(0)


def run_cmd(cmd):
    print("> Executing `{}`".format(cmd))
    err = os.system(cmd)
    if err:
        print("{}/{}: command '{}' failed with code {}".format(cat, pn, cmd, err))
    return err


def update_pkg(cat, pn, slot, from_v, to_v):
    global LOCK

    os.chdir("{}/{}/{}".format(PORTDIR_OVERLAY, cat, pn))

    LOCK.acquire()
    if slot == "latest":
        run_cmd('cp -v {0}-{1}*.ebuild {0}-{2}.ebuild'.format(pn, from_v, to_v))
    else: # bump inside a slot
        run_cmd('git mv -v {0}-{1}*.ebuild {0}-{2}.ebuild'.format(pn, from_v, to_v))
    LOCK.release()

    if run_cmd('repoman manifest') != 0:
        LOCK.acquire()
        run_cmd('git checkout -- .')
        LOCK.release()
        return 1

    LOCK.acquire()
    run_cmd('git add {}-{}.ebuild'.format(pn, to_v))
    if slot == "latest":
        run_cmd("git commit -m '{}/{}: new version v{}' .".format(cat, pn, to_v))
    else: # bump inside a slot
        run_cmd("git commit -m '{}/{}: bump to v{}' .".format(cat, pn, to_v))
    LOCK.release()

# only one git command may run concurrently
LOCK = Lock()

pool = Pool(4)

for x in table[1:]:
    pool.apply_async(func=update_pkg, args=(x[0], x[1], x[2], x[3], x[4]))

pool.close()
pool.join()
