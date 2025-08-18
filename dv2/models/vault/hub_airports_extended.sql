{%- set yaml_metadata -%}
hashkey: 'hk_airports_extended'
business_keys: 
    - airport_id
    - name
source_models: stg_airports_extended
{%- endset -%}

{{ datavault4dbt.hub(yaml_metadata=yaml_metadata) }}