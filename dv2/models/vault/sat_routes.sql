{%- set yaml_metadata -%}
parent_hashkey: 'hk_routes'
src_hashdiff: 'hd_routes'
src_payload:
    - airline
    - airline_id
    - source_airport
    - source_airport_id
    - destination_airport
    - destination_airport_id
    - codeshare
    - stops
    - equipment
source_model: 'stg_routes'
{%- endset -%}    

{{ datavault4dbt.sat_v0(yaml_metadata=yaml_metadata) }}