with airports as (
    select
        hub.airport_id,
        sat.name,
        sat.city,
        sat.country,
        sat.iata,
        sat.icao,
        sat.latitude,
        sat.longitude,
        sat.altitude,
        sat.timezone,
        sat.dst,
        sat.tz
    from vault.hub_airports as hub
    join vault.sat_airports as sat
        on hub.hk_airports = sat.hk_airports
),
routes as (
    select
        sat.airline,
        sat.airline_id,
        sat.source_airport,
        sat.source_airport_id,
        sat.destination_airport,
        sat.destination_airport_id,
        sat.equipment
    from vault.sat_routes as sat
)
-- number of airlines that operate from or to each airport
select
    a.airport_id,
    a.name,
    a.city,
    a.country,
    a.iata,
    a.icao,
    a.latitude,
    a.longitude,
    a.altitude,
    a.timezone,
    a.dst,
    a.tz,
    count(distinct r.airline_id) as airline_count
from airports a
join routes r
    on a.airport_id = r.source_airport_id
    or a.airport_id = r.destination_airport_id
group by
    a.airport_id,
    a.name,
    a.city,
    a.country,
    a.iata,
    a.icao,
    a.latitude,
    a.longitude,
    a.altitude,
    a.timezone,
    a.dst,
    a.tz
order by airline_count desc