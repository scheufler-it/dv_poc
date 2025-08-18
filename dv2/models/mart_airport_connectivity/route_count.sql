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
),
planes as (
    select
        sat.name,
        sat.icao_code,
        hub.iata_code
    from vault.sat_planes as sat
    join vault.hub_planes as hub
        on sat.hk_planes = hub.hk_planes
)
-- count of flights from and to the airport
select
    airport_id,
    name,
    city,
    country,
    iata,
    icao,
    latitude,
    longitude,
    altitude,
    timezone,
    dst,
    tz,
    count(*) as flight_count
from airports p
join routes r
	on p.airport_id = r.source_airport_id
	or p.airport_id = r.destination_airport_id
group by airport_id,
		name,
	   	city,
	    country,
	    iata,
	    icao,
	    latitude,
	    longitude,
	    altitude,
	    timezone,
	    dst,
	    tz
order by flight_count desc