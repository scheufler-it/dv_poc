{%- set yaml_metadata -%}
hashkey: 'hk_airlines'
business_keys: 
    - airline_id
    - name
source_models: stg_airlines
{%- endset -%}

{{ datavault4dbt.hub(yaml_metadata=yaml_metadata) }}