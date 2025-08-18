{%- set yaml_metadata -%}
parent_hashkey: 'hk_airports'
src_hashdiff: 'hd_airports'
src_payload:
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
source_model: 'stg_airports'
{%- endset -%}    

{{ datavault4dbt.sat_v0(yaml_metadata=yaml_metadata) }}