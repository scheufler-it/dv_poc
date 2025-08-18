{%- set yaml_metadata -%}
hashkey: 'hk_routes'
business_keys: 
    - route_id
source_models: stg_routes
{%- endset -%}

{{ datavault4dbt.hub(yaml_metadata=yaml_metadata) }}