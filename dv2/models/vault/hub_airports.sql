{%- set yaml_metadata -%}
hashkey: 'hk_airports'
business_keys: 
    - airport_id
source_models: stg_airports
{%- endset -%}

{{ datavault4dbt.hub(yaml_metadata=yaml_metadata) }}