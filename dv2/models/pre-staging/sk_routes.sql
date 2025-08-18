with routes as (
    select
        "Airline" as airline,
        "Airline_ID" as airline_id,
        "Source_airport" as source_airport,
        "Source_airport_ID" as source_airport_id,
        "Destination_airport" as destination_airport,
        "Destination_airport_ID" as destination_airport_id,
        "Codeshare" as codeshare,
        "Stops" as stops,
        "Equipment" as equipment

    from {{ source('dv', 'routes') }}
)

select
    (airline || airline_id || source_airport || source_airport_id || 
    destination_airport || destination_airport_id || codeshare || stops || 
    equipment) as route_id,
    *
from routes