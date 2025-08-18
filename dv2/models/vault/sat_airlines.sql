{%- set yaml_metadata -%}
parent_hashkey: 'hk_airlines'
src_hashdiff: 'hd_airlines'
src_payload:
    - name
    - alias
    - iata
    - icao
    - callsign
    - country
    - active
source_model: 'stg_airlines'
{%- endset -%}    

{{ datavault4dbt.sat_v0(yaml_metadata=yaml_metadata) }}