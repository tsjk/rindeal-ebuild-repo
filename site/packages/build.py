#!/usr/bin/env python3

import jinja2
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

fs_loader = jinja2.FileSystemLoader(SCRIPT_DIR + '/templates')
jinja_env = jinja2.Environment(
        loader = fs_loader,
        autoescape = True,
        trim_blocks = True,
        lstrip_blocks = True
    )

template = jinja_env.get_template('pages/index.html')
print(template.render(name='John Doe'))

# find PORTDIR_OVERLAY
dir = SCRIPT_DIR+"/foo"
while len(dir):
    dir = os.path.dirname(dir)
    if not os.path.isfile(dir + "/metadata/layout.conf"):
        continue
    PORTDIR_OVERLAY = dir
    break

os.environ["PORTDIR_OVERLAY"]=PORTDIR_OVERLAY

import portage
portage_db = portage.db[portage.root]["porttree"].dbapi
