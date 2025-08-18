{%- set yaml_metadata -%}
source_model: 'planes'
ldts: CURRENT_TIMESTAMP
rsrc: '!landing_zone.planes'
include_source_columns: true
hashed_columns:
    hk_planes:
        - iata_code
    hd_planes:
        - name
        - icao_code
{%- endset -%}

{{ datavault4dbt.stage(yaml_metadata=yaml_metadata) }}