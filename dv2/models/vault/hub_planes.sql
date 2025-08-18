{%- set yaml_metadata -%}
hashkey: 'hk_planes'
business_keys: 
    - iata_code
source_models: stg_planes
{%- endset -%}

{{ datavault4dbt.hub(yaml_metadata=yaml_metadata) }}