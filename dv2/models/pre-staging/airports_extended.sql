{% set src_relation = source('dv','airports_extended') %}
{% set cols = adapter.get_columns_in_relation(src_relation) %}

select
    {%- for col in cols %}
        "{{ col.name }}" as {{ col.name | lower }}{{ "," if not loop.last }}
    {%- endfor %}
from {{ src_relation }}