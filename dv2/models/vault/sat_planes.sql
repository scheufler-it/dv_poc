{%- set yaml_metadata -%}
parent_hashkey: 'hk_planes'
src_hashdiff: 'hd_planes'
src_payload:
    - name
    - icao_code
source_model: 'stg_planes'
{%- endset -%}    

{{ datavault4dbt.sat_v0(yaml_metadata=yaml_metadata) }}