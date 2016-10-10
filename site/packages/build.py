#!/usr/bin/env python3

import jinja2
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

fs_loader = jinja2.FileSystemLoader(SCRIPT_DIR + '/templates')
jinja_env = jinja2.Environment(
        loader=fs_loader,
        autoescape=true
    )

template = jinja_env.get_template('mytemplate.html')
template.render(name='John Doe')
