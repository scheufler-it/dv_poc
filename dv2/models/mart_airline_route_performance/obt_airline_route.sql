with airlines as (
with hub as (
    select * from vault.hub_airlines
),
sat as (
    select * from vault.sat_airlines
)

select
    hub.airline_id,
    hub.name,
    sat.alias,
    sat.iata,
    sat.icao,
    sat.callsign,
    sat.country,
    sat.active
from hub
join sat
    on hub.hk_airlines = sat.hk_airlines
),

routes as (
with hub as (
    select * from vault.hub_routes),
sat as (
    select * from vault.sat_routes
)

select
    hub.route_id,
	sat.airline,
	sat.airline_id as id_airline,
	sat.source_airport,
	sat.source_airport_id,
	sat.destination_airport,
	sat.destination_airport_id,
	sat.codeshare,
	sat.stops,
	sat.equipment
from hub
join sat
    on hub.hk_routes = sat.hk_routes
)

select 
    airlines.*,
    routes.*
from airlines
join routes on
    airlines.airline_id::varchar = routes.id_airline::varchar