{%- set yaml_metadata -%}
source_model: 'sk_routes'
ldts: CURRENT_TIMESTAMP
rsrc: '!landing_zone.routes'
include_source_columns: true
hashed_columns:
    hk_routes:
        - route_id
    hd_routes:
        is_hashdiff: true
        columns:
            - airline
            - airline_id
            - source_airport
            - source_airport_id
            - destination_airport
            - destination_airport_id
            - codeshare
            - stops
            - equipment
    hk_airlines:
        - airline_id
    hk_routes_airlines:
        - route_id
        - airline_id
    hk_source_airports:
        - source_airport_id
    hk_routes_source_airports:
        - route_id
        - source_airport_id
    hk_destination_airports:
        - destination_airport_id
    hk_routes_destination_airports:
        - route_id
        - destination_airport_id
    hk_planes:
        - equipment
    hk_routes_planes:
        - route_id
        - equipment
{%- endset -%}

{{ datavault4dbt.stage(yaml_metadata=yaml_metadata) }}