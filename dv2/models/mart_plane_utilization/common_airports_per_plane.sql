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
    join sat on hub.hk_airlines = sat.hk_airlines
),

routes as (
    with hub as (
        select * from vault.hub_routes
    ),
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
    join sat on hub.hk_routes = sat.hk_routes
),

planes as (
    with hub as (
        select * from vault.hub_planes
    ),
    sat as (
        select * from vault.sat_planes
    )
    select
        hub.iata_code,
        sat.name,
        sat.icao_code
    from hub
    join sat on hub.hk_planes = sat.hk_planes
),

airports as (
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

routes_with_planes as (
    select
        r.equipment as plane_code,
        p.name as plane_name,
        r.source_airport,
        r.destination_airport
    from routes r
    join planes p
        on r.equipment = p.iata_code
),

ranked_sources as (
    select
        plane_name,
        source_airport,
        count(*) as flights,
        row_number() over (
            partition by plane_name
            order by count(*) desc
        ) as rn
    from routes_with_planes
    group by plane_name, source_airport
),

ranked_destinations as (
    select
        plane_name,
        destination_airport,
        count(*) as flights,
        row_number() over (
            partition by plane_name
            order by count(*) desc
        ) as rn
    from routes_with_planes
    group by plane_name, destination_airport
)

select
    s.plane_name,
    sa.name as source_airport_name,
    sa.city as source_city,
    sa.country as source_country,
    sa.iata as source_iata,
    sa.icao as source_icao,
    da.name as destination_airport_name,
    da.city as destination_city,
    da.country as destination_country,
    da.iata as destination_iata,
    da.icao as destination_icao
from ranked_sources s
join ranked_destinations d
    on s.plane_name = d.plane_name
join airports sa
    on s.source_airport = sa.iata
join airports da
    on d.destination_airport = da.iata
where s.rn = 1
  and d.rn = 1
order by s.plane_name