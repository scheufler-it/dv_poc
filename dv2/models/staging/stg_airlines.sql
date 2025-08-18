{%- set yaml_metadata -%}
source_model: 'airlines'
ldts: CURRENT_TIMESTAMP
rsrc: '!landing_zone.airlines'
include_source_columns: true
hashed_columns:
    hk_airlines:
        - airline_id
    hd_airlines:
        is_hashdiff: true
        columns:
            - name
            - alias
            - iata
            - icao
            - callsign
            - country
            - active
{%- endset -%}

{{ datavault4dbt.stage(yaml_metadata=yaml_metadata) }}