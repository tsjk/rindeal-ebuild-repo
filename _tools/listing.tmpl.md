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

{% macro catlink(cat) -%}
    {{-''-}} #user-content-{{ catid(cat) }}
{%- endmacro -%}

{% macro pkgid(cat, pn) -%}
    {{-''-}} pkg-{{ cat }}---{{ pn }}
{%- endmacro -%}

{% macro pkglink(cat, pn) -%}
    {{-''-}} #user-content-{{ pkgid(cat, pn) }}
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

    {#- delimiter #}
    {{- ' | ' -}}

    {##
        second column
            - package names enum
    ##}
    {% for pkg in categories[cat] | sort %}
        {# do not print comma for the first package #}
        {% if loop.index > 1 %}
            {{- ', ' -}}
        {% endif -%}

        {# package name with an embedded link to the package location in the full list #}
        {{-''}}[{{ pkg }}]({{ pkglink(cat, pkg) }}){{''-}}
    {% endfor %}

    {#- new line #}
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
        [:back:]({{ catlink(c) }})
    {% endfor %}
{% endfor %}

{# make some vertical space so that scrolling past end works correctly #}
{% for i in range(1, 20) %}
    {{ "\n&nbsp;" }}
{% endfor %}
