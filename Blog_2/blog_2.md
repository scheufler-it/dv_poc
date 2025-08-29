# 1 Data Vault 2.0 Overview

In the last blog post, we discussed a basic overview of Data Vault 2.0, its principles, methodology, and approach to data modeling. In this entry, we'll implement an example Data Vault to hopefully get a more practical understanding of how the different pieces fit together.

We use the **OpenFlights** dataset and use it as our raw source tables and we host our data warehouse locally on **PostgreSQL**. For data modeling, we use **dbt** alongside the **DataVault4dbt** package created by **Scalefree**. Of course, one could also manually implement the Data Vault logic, but we would not recommend that for most applications as several automation tools already exist and using them saves time and reduces complexity.

The [source code](https://github.com/scheufler-it/dv_poc) is available if you wish to take a closer look at the implementation and of course, as always, please do not hesitate to contact with any questions or comments you may have. With all that said, let's dive in!

# 2 Staging Layer

Looking at our six source tables, we have an **airlines** table, an **airports** and an **airports_extended** table, a countries table, a **planes** table, and a **routes** table. The entire dataset is modeled in a star schema with the routes table acting as a facts table and everything else as dimension tables. These raw source tables can be seen in our source code under the 'OpenFlights' folder.

We start with the staging layer,  where we standardize raw sources. As a first step, we define our dbt sources (which are simply the raw source tables) in our sources YAML:

```yaml
version: 2

sources:
    - name: dv
      database: dv
      schema: landing_zone
      tables:
        - name: airlines
        - name: airports
        - name: airports_extended
        - name: countries
        - name: planes
        - name: routes
```

Next, we need to rename the tables abd columns to be lower snake case due to some PostgresSQL-specific syntax requirements to avoid errors later on. The nice thing about dbt is that these sort of operations can easily be done through some Jinja scripting. Here's how we rename the columns of the airlines table as an example:

```yaml
{% set src_relation = source('dv','airlines') %}
{% set cols = adapter.get_columns_in_relation(src_relation) %}

select
    {%- for col in cols %}
        "{{ col.name }}" as {{ col.name | lower }}{{ "," if not loop.last }}
    {%- endfor %}
from {{ src_relation }}
```

Once we're done with the renaming, we can start the actual staging step, which essentially boils down to hashing our primary key columns, adding hash diffs for change data capture in our satellites later down the line, and a few other steps. Luckily for us, we can do this using DataVault4dbt's stage macro, which implements the staging logic for us. Here is the staging code for the airlines table:

```yaml
{%- set yaml_metadata -%}
source_model: 'airlines'
ldts: CURRENT_TIMESTAMP
rsrc: '!landing_zone.airlines'
include_source_columns: true
hashed_columns:
    hk_airlines:
        - airline_id
    hd_airlines:
        is_hashdiff: true
        columns:
            - name
            - alias
            - iata
            - icao
            - callsign
            - country
            - active
{%- endset -%}

{{ datavault4dbt.stage(yaml_metadata=yaml_metadata) }}
```

And believe or not, that's it for staging! We simply repeat the same step for all of our tables and we have our staging tables. Of course, in reality there would be more steps involved. For example, we are not really performing data checks, which if you ask any good data engineer, would quickly tell you is a recipe for disaster, however in our case here, we are using an already cleaned dataset and data testing is not essential to demonstrating the modeling approach.

# 3 Raw Vault

The next step after staging is to implement our raw vault, and just like before, DataVault4dbt provides macros for creating hubs, links, and satellites. The exact way you would approach modeling your data here is case-specific and depends on what you need from your EDW. In our case, we treat each source table as a core business entity and therefore define a hub for it. Here's how the airlines hub is defined:

```yaml
{%- set yaml_metadata -%}
hashkey: 'hk_airlines'
business_keys: 
    - airline_id
    - name
source_models: stg_airlines
{%- endset -%}

{{ datavault4dbt.hub(yaml_metadata=yaml_metadata) }}
```

Notice how we only take the business key associated with the airline entity in our hub. All other descriptive attributes go into the satellites. The hubs store unique business keys plus metadata for lineage and auditing.

Once we defined all hubs, we need to connect them using links. Here is an example of a link between routes and airlines:

```yaml
{%- set yaml_metadata -%}
link_hashkey: 'hk_routes_airlines'
foreign_hashkeys: 
    - 'hk_routes'
    - 'hk_airlines'
source_models: 
    - name: stg_routes
{%- endset -%}    

{{ datavault4dbt.link(yaml_metadata=yaml_metadata) }}
```

As you can see we are using the routes and airlines hub hashkeys as inputs to generate the routes_airlines link hashkey, which uniquely identifies each relationship between a route and an airline. This way, the links model many-to-many relationships between hubs and carry their own metadata.

Last but not least, we generate satellite tables for the descriptive attributes of each hub. Please keep in mind that links also can and often do have satellites as well, but in our example we omit them. The airlines satellite is created like this:

```yaml
{%- set yaml_metadata -%}
parent_hashkey: 'hk_airlines'
src_hashdiff: 'hd_airlines'
src_payload:
    - name
    - alias
    - iata
    - icao
    - callsign
    - country
    - active
source_model: 'stg_airlines'
{%- endset -%}    

{{ datavault4dbt.sat_v0(yaml_metadata=yaml_metadata) }}
```

Once we have all of our hubs, links, and satellites, we have essentially set up our raw vault! At this point, I hope you are starting to see why using automation tools like DataVault4dbt is so powerful.

One last note as well before we move on, we do not implement a business vault in our example either. However, implementing a business vault once you have your raw vault is very simple. Below is the Directed Acyclic Graph (DAG) of the completed dbt project.

- Pic of DAG

# 4 Information Marts

This step is straightforward once the vault is in place. In our information/data marts, we create ad-hoc and custom queries and tables from our data in the vault to create useful insights for the business. You can also hopefully see why the Data Vault 2.0 modeling approach is so powerful, as any changes or additions to our data structure from our source systems can easily be accommodated into our vault. Once we have the vault set up as our single source of truth, creating the required marts is a question of simply picking what we need. In a real implementation, we would usually surface marts from the vault via Point In Time (PIT) and Bridge tables to serve BI.

In our example, we implement three different marts to demonstrate various BI requirements:

- an OBT (One Big Table) for business analysts to examine the performance of different routes and airlines,
- a mart for evaluating the connectivity of each airport,
- as well as a mart for analyzing the overall utilization of aircraft types.

Since these are rather long ad-hoc queries, we do not list them here, but we strongly recommend analyzing them yourself. The result of the aircraft type usage is shown below:

- Image of aircraft usage

# 5 dbt Features

We hope the implementation above has demonstrated the need for repeatable and consistent logic when setting up a Data Vault 2.0. We personally really like dbt as it makes the entire data modeling experience a much more pleasant and faster experience, and having packages such as DataVault4dbt or dbtutils, etc. makes it so that you can very quickly set things up and deploy. 

As mentioned before, there are other tools that one could use and there even exists another package for dbt which is also an implementation of Data Vault 2.0 (AutomateDV). At the end of the day, we think you should use whatever tool you feel most comfortable with and the main goal of this blog was to demonstrate Data Vault 2.0 modeling and not a specific tool.

# 6 Concluding Remarks

We hope that through this basic practical implementation, you now have a better understanding of Data Vault 2.0 and all of its core components. Should you want to dig deeper into Data Vault 2.0, do check out all of our sources. 

Whether you should or should not use Data Vault is a rather important and nuanced question that you should carefully consider depending on the nature of your data sources, business intelligence needs, and data volume, amongst other factors. 

We would be happy to hear what you think of this blog series, alongside any other comments, feedback, or questions you might have. Thank you  and see you next time!

# Sources

- Scalefree (no date) *Data Vault 2.0 definition*. Available at: https://www.scalefree.com/consulting/data-vault-2-0/ (Accessed: 28 August 2025).
- Linstedt, D. and Olschimke, M. (2015) *Building a scalable data warehouse with Data Vault 2.0*. Waltham, MA: Morgan Kaufmann.
- Scalefree International GmbH (2025) *DataVault4dbt*. Available at: https://www.datavault4dbt.com/ (Accessed: 29 August 2025).
- OpenFlights.org (2025) *OpenFlights.org: Flight logging, mapping, stats and sharing*. Available at: https://openflights.org(Accessed: 29 August 2025).
- dbt Labs (2025) *Transform your data with dbt*. Available at: https://www.getdbt.com/lp/dbt-the-data-build-tool (Accessed: 29 August 2025).
- PostgreSQL Global Development Group (2025) *PostgreSQL: The world’s most advanced open source database*. Available at: https://www.postgresql.org (Accessed: 29 August 2025).
