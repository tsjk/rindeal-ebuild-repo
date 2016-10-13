{#
    Copyright 2016 Jan Chren (rindeal) <dev.rindeal@gmail.com>
    Distributed under the terms of the GNU General Public License v2
#}
{#
    jinja2 template for LISTING.md
#}
{% macro catid(cat) -%}
    {{-''-}} cat-{{ cat }}
{%- endmacro -%}

{% macro pkgid(cat, pn) -%}
    {{-''-}} pkg-{{ cat }}---{{ pn }}
{%- endmacro -%}

<a id="top"></a>

Category | Packages
-------- | --------
{# no empty line #}
{% for cat in categories | sort %}
    {##
        first column
            - category name
    ##}
    {{-''}}<a id="{{ catid(cat) }}"></a>**{{ cat }}**

    {{- ' | ' -}}

    {##
        second column
            - package names enum
    ##}
    {% set first_pkg = True %}
    {% for pkg in categories[cat] | sort %}
        {# do not print comma for the first package #}
        {% if first_pkg %}
            {% set first_pkg = False %}
        {% else %}
            {{- ', ' -}}
        {% endif %}
    {# package name with an embedded link to the package location in the full list #}
    {{-''}}[{{ pkg }}](#{{ pkgid(cat, pkg) }}){{''-}}

    {% endfor %}
    {# new line #}
    {{''}}
{% endfor %}

----------------------------------------------------------------------------------------------------

Package | Description | :house: | :back:
------- | ----------- | ------- | ------
{# no empty line #}
{% for c in categories | sort %}
    {% for p in categories[c] | sort %}
        {% set pkg = categories[c][p] %}
        {{-''}}<a id="{{pkgid(c, p)}}"></a><a href="./{{c}}/{{p}}"><sub><sup>{{c}}/</sup></sub><strong>{{p}}</strong></a>
        {{- ' | ' -}}
        {{ pkg.desc }}
        {{- ' | ' -}}
        [:house:]({{ pkg.home }})
        {{- ' | ' -}}
        [:back:](#{{ catid(c) }})
    {% endfor %}
{% endfor %}

{# make some vertical space so that scrolling past end works correctly #}
{% for i in range(1, 20) %}
    {{ "\n&nbsp;" }}
{% endfor %}
