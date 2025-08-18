{%- set yaml_metadata -%}
source_model: 'countries'
ldts: CURRENT_TIMESTAMP
rsrc: '!landing_zone.countries'
include_source_columns: true
hashed_columns:
    hk_countries:
        - name
        - iso_code
        - dafif_code
{%- endset -%}

{{ datavault4dbt.stage(yaml_metadata=yaml_metadata) }}