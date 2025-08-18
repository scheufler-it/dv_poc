{%- set yaml_metadata -%}
parent_hashkey: 'hk_airports_extended'
src_hashdiff: 'hd_airports_extended'
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
source_model: 'stg_airports_extended'
{%- endset -%}    

{{ datavault4dbt.sat_v0(yaml_metadata=yaml_metadata) }}