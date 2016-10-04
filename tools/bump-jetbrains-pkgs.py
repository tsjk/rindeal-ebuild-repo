#!/usr/bin/env python3

import requests
import portage
import os
import glob
from terminaltables import AsciiTable
from multiprocessing import Process
import subprocess

PORTDIR_OVERLAY=os.path.realpath(os.path.dirname(os.path.realpath(__file__)) + "/../")
os.chdir(PORTDIR_OVERLAY)
os.environ["PORTDIR_OVERLAY"] = PORTDIR_OVERLAY

def get_version( codes ):
    payload = {
        'code': ','.join(codes),
        'latest': 'true',
        'type': 'release'
    }
    r = requests.get('https://data.services.jetbrains.com/products/releases', params=payload)
    json=r.json()
    versions = {}
    for c in codes:
        versions[c]=json[c][0]['version']
    return versions

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

table=[ [ 'Category', 'Package', 'Current version', 'New version' ] ]

for pn, code in codes.items():
    cat = glob.glob("*/{}/".format(pn))[0].split("/")[0]
    pkg = pdb.xmatch('bestmatch-visible', '{}/{}::rindeal'.format(cat, pn))
    old_ver = portage.pkgsplit(pkg)[1]
    new_ver = versions[code]
    if portage.vercmp(old_ver, new_ver) < 0:
        table.append([cat, pn, old_ver, new_ver])

print(AsciiTable(table).table)

def update_pkg(cat, pn, from_v, to_v):
    os.chdir("{}/{}".format(cat, pn))
    cmds=[
        'mv -v {0}-{1}*.ebuild {0}-{2}.ebuild'.format(pn, from_v, to_v),
        'repoman manifest',
        'git add .',
        "git commit -m '{}/{}: bump to v{}' .".format(cat, pn, to_v)
    ]
    for cmd in cmds:
        err = os.system(cmd)
        if err:
            print("{}/{}: command '{}' failed with code {}".format(cat, pn, cmd, err))
            return 1
print("cwd={}".format(os.getcwd()))

y = input("Press 'y' to proceed with the update\n")
if y != "y":
    print("You pressed '{}', bailing...".format(y))
    exit(0)

processes = []

for update in table[1:]:
    processes.append(Process(target=update_pkg, args=(update[0], update[1], update[2], update[3])))

for p in processes:
    p.start()

for p in processes:
    p.join()
