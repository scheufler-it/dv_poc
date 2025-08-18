{%- set yaml_metadata -%}
link_hashkey: 'hk_routes_airlines'
foreign_hashkeys: 
    - 'hk_routes'
    - 'hk_airlines'
source_models: 
    - name: stg_routes
{%- endset -%}    

{{ datavault4dbt.link(yaml_metadata=yaml_metadata) }}