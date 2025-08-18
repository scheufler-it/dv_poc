{%- set yaml_metadata -%}
link_hashkey: 'hk_routes_source_airports'
foreign_hashkeys: 
    - 'hk_routes'
    - 'hk_source_airports'
source_models: 
    - name: stg_routes
{%- endset -%}    

{{ datavault4dbt.link(yaml_metadata=yaml_metadata) }}