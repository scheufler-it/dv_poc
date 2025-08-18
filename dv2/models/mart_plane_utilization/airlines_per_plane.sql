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
),

planes as (
with hub as (
    select * from vault.hub_planes),
sat as (
    select * from vault.sat_planes
)

select
    hub.iata_code,
    sat.name,
    sat.icao_code
from hub
join sat
    on hub.hk_planes = sat.hk_planes
)
-- number of airlines using each plane type
select
    p.iata_code,
    p.name,
    p.icao_code,
    count(distinct r.id_airline) as airline_count
from routes r
join planes p
    on p.iata_code = r.equipment
group by
    p.iata_code,
    p.name,
    p.icao_code
order by airline_count desc