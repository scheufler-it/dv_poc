{%- set yaml_metadata -%}
source_model: 'airports'
ldts: CURRENT_TIMESTAMP
rsrc: '!landing_zone.airports'
include_source_columns: true
hashed_columns:
    hk_airports:
        - airport_id
    hd_airports:
        is_hashdiff: true
        columns:
            - name
            - city
            - country
            - iata
            - icao
            - latitude
            - longitude
            - altitude
            - timezone
            - dst
            - tz
            - type
            - source
{%- endset -%}

{{ datavault4dbt.stage(yaml_metadata=yaml_metadata) }}