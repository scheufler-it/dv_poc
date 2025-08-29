# 1 Data Vault 2.0 Überblick

Im letzten Blogbeitrag haben wir einen grundlegenden Überblick über Data Vault 2.0, seine Prinzipien, Methodik und den Ansatz zum Datenmodellieren besprochen. In diesem Beitrag implementieren wir ein Beispiel-Data-Vault, um hoffentlich ein praktischeres Verständnis dafür zu bekommen, wie die einzelnen Teile zusammenpassen.

Wir verwenden den **OpenFlights**-Datensatz als Roh-Quelltabellen und hosten unser Data Warehouse lokal auf **PostgreSQL**. Für das Datenmodellieren setzen wir **dbt** zusammen mit dem von **Scalefree** entwickelten **DataVault4dbt-Paket** ein. Natürlich könnte man die Data-Vault-Logik auch manuell implementieren, aber wir würden das für die meisten Anwendungen nicht empfehlen, da es bereits mehrere Automatisierungstools gibt, deren Nutzung Zeit spart und die Komplexität reduziert.

Der [Quellcode](https://github.com/scheufler-it/dv_poc) ist verfügbar, falls Sie einen genaueren Blick auf die Implementierung werfen möchten, und natürlich gilt wie immer: Bitte zögern Sie nicht, uns bei Fragen oder Kommentaren zu kontaktieren. Mit all dem gesagt: legen wir los!

# 2 Staging

Wenn wir uns unsere sechs Quelltabellen ansehen, haben wir eine **airlines-Tabelle**, eine **airports-** und eine **airports_extended-Tabelle**, eine **countries-Tabelle**, eine **planes-Tabelle** sowie eine **routes-Tabelle**. Der gesamte Datensatz ist in einem Sternschema modelliert, wobei die routes-Tabelle als Faktentabelle fungiert und alles andere als Dimensionstabellen. Diese Roh-Quelltabellen finden sich in unserem Quellcode im Ordner *OpenFlights*.

Wir beginnen mit der Staging-Schicht, in der wir die Rohquellen standardisieren. Als ersten Schritt definieren wir unsere dbt-Sources (das sind einfach die Roh-Quelltabellen) in unserer sources YAML:

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

Als Nächstes müssen wir Tabellen- und Spaltennamen in lower snake_case umbenennen, da dies aufgrund PostgreSQL-spezifischer Syntaxanforderungen notwendig ist, um Fehler zu vermeiden. Das Schöne an dbt ist, dass sich solche Operationen sehr einfach mit etwas Jinja-Scripting durchführen lassen. Hier ein Beispiel, wie wir die Spalten der airlines-Tabelle umbenennen:

```yaml
{% set src_relation = source('dv','airlines') %}
{% set cols = adapter.get_columns_in_relation(src_relation) %}

select
    {%- for col in cols %}
        "{{ col.name }}" as {{ col.name | lower }}{{ "," if not loop.last }}
    {%- endfor %}
from {{ src_relation }}
```

Sobald wir mit dem Umbenennen fertig sind, können wir den eigentlichen Staging-Schritt starten. Im Wesentlichen läuft dieser darauf hinaus, unsere Primärschlüssel-Spalten zu hashen, Hash-Diffs für Change Data Capture in späteren Satelliten hinzuzufügen und ein paar weitere Schritte durchzuführen. Glücklicherweise können wir das mit dem stage-Makro von DataVault4dbt erledigen, das die Staging-Logik für uns implementiert. Hier der Staging-Code für die airlines-Tabelle:
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

{{ datavault4dbt.stage(yaml_metadata=yaml_metadata)
```
Und glauben Sie es oder nicht, damit ist das Staging erledigt! Wir wiederholen diesen Schritt einfach für alle Tabellen und haben damit unsere Staging-Tabellen erstellt. Natürlich wären in einer realen Implementierung mehr Schritte nötig. Beispielsweise führen wir hier keine Datenprüfungen durch, was, wie jeder gute Data Engineer sofort sagen würde, ein Rezept für Desaster ist. Da wir aber in unserem Fall einen bereits bereinigten Datensatz verwenden, ist Data Testing hier nicht essenziell, um den Modellierungsansatz zu demonstrieren.
# 3 Raw Vault
Der nächste Schritt nach dem Staging ist die Implementierung unseres Raw Vaults, und wie zuvor stellt uns DataVault4dbt Makros zum Erstellen von Hubs, Links und Satelliten bereit. Die genaue Modellierung hängt vom Anwendungsfall und den Anforderungen an das EDW ab. In unserem Beispiel behandeln wir jede Quelltabelle als Kern-Geschäftseinheit und definieren dafür jeweils einen Hub. Hier das Beispiel für den airlines-Hub:
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
Beachten Sie, dass wir im Hub nur den Business Key der Airline-Entität aufnehmen. Alle anderen beschreibenden Attribute wandern in die Satelliten. Hubs speichern eindeutige Business Keys sowie Metadaten für Lineage und Auditing.

Sobald alle Hubs definiert sind, müssen wir sie über Links verbinden. Hier ein Beispiel für einen Link zwischen routes und airlines:
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
Wie man sieht, verwenden wir die Hashkeys von routes und airlines als Eingaben, um den routes_airlines-Link-Hashkey zu generieren, der jede Beziehung zwischen einer Route und einer Airline eindeutig identifiziert. Auf diese Weise modellieren Links viele-zu-viele-Beziehungen zwischen Hubs und enthalten ihre eigenen Metadaten.

Zuletzt erzeugen wir Satelliten-Tabellen für die beschreibenden Attribute jedes Hubs. Bitte beachten: Auch Links können und tun dies oft ebenfalls, aber in unserem Beispiel lassen wir sie weg. Hier der Airlines-Satellit:
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
Sobald wir alle Hubs, Links und Satelliten haben, ist unser Raw Vault im Wesentlichen fertig! An diesem Punkt sollte deutlich werden, warum der Einsatz von Automatisierungstools wie DataVault4dbt so mächtig ist.

Noch eine Anmerkung: In unserem Beispiel implementieren wir keinen Business Vault. Die Implementierung wäre jedoch sehr einfach, sobald ein Raw Vault steht. Unten sehen Sie den Directed Acyclic Graph (DAG) des abgeschlossenen dbt-Projekts.
- Bild des DAG
# 4 Informations-Marts
Dieser Schritt ist recht geradlinig, sobald das Vault steht. In unseren Informations- bzw. Data Marts erstellen wir Ad-hoc- und benutzerdefinierte Abfragen und Tabellen aus den Vault-Daten, um nützliche Erkenntnisse für das Geschäft zu generieren. Hier zeigt sich auch, warum der Data-Vault-2.0-Ansatz so mächtig ist: Jede Änderung oder Erweiterung unserer Datenstruktur in den Quellsystemen kann problemlos in das Vault integriert werden. Sobald das Vault als Single Source of Truth etabliert ist, besteht die Erstellung von Marts einfach darin, die benötigten Daten auszuwählen. In einer realen Implementierung würden Marts in der Regel über Point-in-Time (PIT)- und Bridge-Tabellen für BI verfügbar gemacht.

In unserem Beispiel implementieren wir drei verschiedene Marts, um unterschiedliche BI-Anforderungen zu demonstrieren:

- ein OBT (One Big Table) für Business-Analysten, um die Performance verschiedener Routen und Airlines zu untersuchen,
- ein Mart zur Bewertung der Konnektivität jedes Flughafens,
- sowie ein Mart zur Analyse der Auslastung der Flugzeugtypen insgesamt.

Da es sich hierbei um recht lange Ad-hoc-Queries handelt, führen wir sie hier nicht auf, empfehlen aber dringend, sie selbst zu analysieren. Das Ergebnis der Flugzeugtypen-Nutzung ist unten dargestellt:

- Bild der Flugzeugnutzung

# 5 dbt-Features
Wir hoffen, dass die obige Implementierung gezeigt hat, wie wichtig wiederholbare und konsistente Logik beim Aufbau eines Data Vault 2.0 ist. Wir persönlich mögen dbt sehr, da es den gesamten Datenmodellierungsprozess angenehmer und schneller macht. Pakete wie DataVault4dbt oder dbtutils ermöglichen es zudem, Dinge sehr schnell einzurichten und zu deployen.

Wie bereits erwähnt, gibt es auch andere Tools. Es existiert sogar ein weiteres dbt-Paket, das ebenfalls eine Data-Vault-2.0-Implementierung darstellt (AutomateDV). Letztlich sollte man das Tool wählen, mit dem man sich am wohlsten fühlt. Das Hauptziel dieses Blogs war es, Data Vault 2.0 Modellierung zu demonstrieren, nicht ein spezifisches Tool.

# 6 Schlussbemerkungen
Wir hoffen, dass Sie durch diese einfache praktische Implementierung nun ein besseres Verständnis für Data Vault 2.0 und alle seine Kernkomponenten haben. Wenn Sie tiefer in das Thema einsteigen möchten, schauen Sie sich bitte unsere Quellen an.

Ob Sie Data Vault einsetzen sollten oder nicht, ist eine wichtige und vielschichtige Frage, die Sie sorgfältig anhand Ihrer Datenquellen, BI-Anforderungen und Datenvolumina sowie weiterer Faktoren abwägen sollten.

Wir würden uns sehr über Ihr Feedback zu dieser Blogserie freuen, ebenso wie über Kommentare, Anmerkungen oder Fragen. Vielen Dank und bis zum nächsten Mal!@

# Quellen
- Scalefree (kein Datum) Data Vault 2.0 definition. Verfügbar unter: https://www.scalefree.com/consulting/data-vault-2-0/ (Zugriff: 28. August 2025).
- Linstedt, D. und Olschimke, M. (2015) Building a scalable data warehouse with Data Vault 2.0. Waltham, MA: Morgan Kaufmann.
- Scalefree International GmbH (2025) DataVault4dbt. Verfügbar unter: https://www.datavault4dbt.com/ (Zugriff: 29. August 2025).
- OpenFlights.org (2025) OpenFlights.org: Flight logging, mapping, stats and sharing. Verfügbar unter: https://openflights.org (Zugriff: 29. August 2025).
- dbt Labs (2025) Transform your data with dbt. Verfügbar unter: https://www.getdbt.com/lp/dbt-the-data-build-tool (Zugriff: 29. August 2025).
- PostgreSQL Global Development Group (2025) PostgreSQL: The world’s most advanced open source database. Verfügbar unter: https://www.postgresql.org (Zugriff: 29. August 2025).