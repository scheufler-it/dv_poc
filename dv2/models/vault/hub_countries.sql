{%- set yaml_metadata -%}
hashkey: 'hk_countries'
business_keys: 
    - name
    - iso_code
    - dafif_code
source_models: stg_countries
{%- endset -%}

{{ datavault4dbt.hub(yaml_metadata=yaml_metadata) }}