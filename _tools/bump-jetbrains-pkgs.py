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

    # [code][slot]
    versions = {}
    for c in codes:
        versions[c] = {}
        all_v_data = json[c]

        # latest version is always the first one
        versions[c]['latest_slot'] = all_v_data[0]['majorVersion']

        # loop over all data and pick the first version from each slot, because the data are already sorted
        for v_data in all_v_data:
            slot = v_data['majorVersion']
            if not slot in versions[c]:
                v = v_data['version']
                versions[c][slot] = v

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

remote_versions = get_version(codes.values())

update_table = [dict() for x in range(0)]

pdb = portage.db[portage.root]["porttree"].dbapi

for pn, code in sorted(codes.items()):
    new_updates = [dict() for x in range(0)]

    # find category by globbing in this repo
    cat = glob.glob("*/{0}/{0}*.ebuild".format(pn))[0].split("/")[0]

    # find the newest version for each slot
    loc_slots = {}
    local_versions = pdb.xmatch('match-visible', '{}/{}::rindeal'.format(cat, pn))
    for v in local_versions:
        slot = pdb.aux_get(v, ["SLOT"])[0]
        # add if not yet present
        if not slot in loc_slots:
            loc_slots[slot] = v
            continue
        # update slot if newer version was found
        if portage.vercmp(loc_slots[slot], v) < 0:
            loc_slots[slot] = v

    # now compare current and server versions for each slot
    for slot in loc_slots:
        pkg = loc_slots[slot]

        loc_ver = portage.pkgsplit(pkg)[1]
        rem_ver = remote_versions[code][slot]

        if portage.vercmp(loc_ver, rem_ver) < 0:
            new_updates.append({
                    'cat': cat,
                    'pn': pn,
                    'loc_slot': slot,
                    'loc_ver': loc_ver,
                    'rem_slot': slot,
                    'rem_ver': rem_ver
                })

    # now look for the newest version outside of any known slots
    latest_loc_pkg = pdb.xmatch('bestmatch-visible', '{}/{}::rindeal'.format(cat, pn))
    latest_loc_ver = portage.pkgsplit(latest_loc_pkg)[1]
    latest_loc_slot = pdb.aux_get(latest_loc_pkg, ["SLOT"])[0]
    latest_rem_slot = remote_versions[code]['latest_slot']
    latest_rem_ver = remote_versions[code][latest_rem_slot]
    if portage.vercmp(latest_loc_ver, latest_rem_ver) < 0:
        # check for duplicates
        is_dup = 0
        for update in new_updates:
            if update['loc_slot'] == latest_rem_slot:
                is_dup = 1
                break

        if not is_dup:
            new_updates.append({
                    'cat': cat,
                    'pn': pn,
                    'loc_slot': latest_loc_slot,
                    'loc_ver': latest_loc_ver,
                    'rem_slot': latest_rem_slot,
                    'rem_ver': latest_rem_ver
                })

    update_table += new_updates


# create a pretty table
pretty_table = [ [ 'Category', 'Package', 'Slot', 'Version' ] ]
for u in update_table:
    slot = u['loc_slot']
    if slot != u['rem_slot']:
        slot += ' -> ' + u['rem_slot']
    pretty_table.append([ u['cat'], u['pn'], slot, u['loc_ver'] + ' -> ' + u['rem_ver'] ])

# now print the table
print(AsciiTable(pretty_table).table)
# and prompt the user for an action
y = input("Press 'y' to proceed with the update\n")
if y != "y":
    print("You pressed '{}', bailing...".format(y))
    exit(0)


def run_cmd(cmd):
    pn = os.path.basename(os.getcwd())
    print("> \033[94m{}\033[0m: `\033[93m{}\033[0m`".format(pn, cmd))
    err = os.system(cmd)
    #err = 0
    if err:
        print("{}: command '{}' failed with code {}".format(pn, cmd, err))
    return err


def update_pkg(cat, pn, loc_slot, loc_ver, rem_slot, rem_ver):
    global LOCK

    os.chdir("{}/{}/{}".format(PORTDIR_OVERLAY, cat, pn))

    new_slot = 0 if loc_slot == rem_slot else 1

    LOCK.acquire()
    if new_slot: # bump into a new slot
        run_cmd('cp -v {0}-{1}*.ebuild {0}-{2}.ebuild'.format(pn, loc_slot, rem_ver))
    else: # bump inside a slot
        run_cmd('git mv -v {0}-{1}*.ebuild {0}-{2}.ebuild'.format(pn, loc_ver, rem_ver))
    LOCK.release()

    if run_cmd('repoman manifest') != 0:
        LOCK.acquire()
        run_cmd('git checkout -- .')
        LOCK.release()
        return 1

    LOCK.acquire()
    run_cmd('git add {}-{}.ebuild'.format(pn, rem_ver))
    if new_slot:
        run_cmd("git commit -m '{}/{}: new version v{}' .".format(cat, pn, rem_ver))
    else: # bump inside a slot
        run_cmd("git commit -m '{}/{}: bump to v{}' .".format(cat, pn, rem_ver))
    LOCK.release()

# only one git command may run concurrently
LOCK = Lock()

#update_pkg(update_table[0])

pool = Pool(4)

for update in update_table:
    pool.apply_async(func=update_pkg, kwds=update)

pool.close()
pool.join()
