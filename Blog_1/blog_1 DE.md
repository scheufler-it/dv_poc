Datenmodellierung steht im Zentrum jedes modernen Enterprise Data Warehouse (EDW), wird jedoch oft vernachlässigt. Dies führt bei steigenden Datenmengen und höheren Aktualisierungsfrequenzen zu Skalierungsengpässen und erheblichen Wartungsproblemen.

Data Vault bietet eine einzigartige Architektur, die Skalierbarkeit, vollständige Nachvollziehbarkeit sowie eine widerstandsfähige, historisierte Änderungsverfolgung vereint. Viele Anwender unterschätzen jedoch die Reichweite und das Potenzial dieser Methode. Während die ursprüngliche Data-Vault-Methodik den Schwerpunkt auf das Modellieren legte, geht Data Vault 2.0 weit darüber hinaus. In ihrem wegweisenden Buch präsentieren Daniel Linstedt und Michael Olschimke Data Vault 2.0 als ein umfassendes „System of Business Intelligence“, das nicht nur Modellierung, sondern auch vollständige, praxisnahe Workflows für das unternehmensweite Datenmanagement bereitstellt.

Einer der Hauptpfeiler von Data Vault ist seine Methodik, die bewährte Unternehmenspraktiken kombiniert. So nutzt Data Vault das **Capability Maturity Model Integration (CMMI)**, um Organisationen dabei zu unterstützen, Schritt für Schritt Reife in ihrem Datenmanagement aufzubauen und die richtigen Fähigkeiten in der richtigen Reihenfolge zu entwickeln. **PMP-Prinzipien (Project Management Professional)** sorgen dafür, dass Projekte im Zeitplan bleiben und einen klaren Geschäftswert liefern. Der **System Development Life Cycle (SDLC)** stellt eine strukturierte, wiederholbare Vorgehensweise für die Entwicklung sicher.

Darüber hinaus integriert Data Vault 2.0 **Six Sigma** und **Total Quality Management (TQM)**, um eine Kultur der Qualität und kontinuierlichen Verbesserung über den gesamten Lebenszyklus hinweg – von der Konzeption bis zum Betrieb – zu etablieren. Schließlich bringt die **Scrum-Methodik** Agilität in die Umsetzung, sodass Teams durch kurze Sprints, enge Zusammenarbeit mit Stakeholdern und iterative Releases flexibel auf sich ändernde Geschäftsanforderungen reagieren können. Eine ausführlichere Diskussion zur Methodik findet sich im Data-Vault-2.0-Buch.

- Abbildung der Methodik aus dem DV2.0-Buch

------

## **Grundlagen der Data-Vault-Modellierung**

Data Vault 2.0 basiert auf drei fundamentalen Modellierungselementen, die das Rückgrat seiner Architektur bilden. Das Verständnis dieser Komponenten ist entscheidend, um nachzuvollziehen, wie Data Vault die Balance zwischen Flexibilität und Performance erreicht. Diese Hauptbausteine sind: **Hubs, Links und Satellites**.

**Hubs** repräsentieren die zentralen Geschäftskonzepte einer Organisation. Was genau verfolgt ein Unternehmen? Diese Elemente bilden die Hubs. Ein Hub enthält lediglich den Geschäftsschlüssel sowie Metadaten wie Ladezeitstempel und Quellinformationen. Man kann sich Hubs als stabile Ankerpunkte im Datenmodell vorstellen. Beispiele: Kunden-Hub, Produkt-Hub, Bestell-Hub usw. Diese Entitäten ändern ihre Identität kaum, weshalb sie sich hervorragend als Hubs eignen. Der große Vorteil liegt in der Einfachheit und Stabilität: Auch wenn sich Kundenattribute im Laufe der Zeit verändern, bleibt der Geschäftsschlüssel konstant.

Das nächste zentrale Konzept sind die **Links**, die Beziehungen und Geschäftsvorfälle zwischen Hubs abbilden. Anders als traditionelle Ansätze (z. B. 3NF), bei denen Fremdschlüssel innerhalb von Entitäten eingebettet sind, lagert Data Vault diese Beziehungen in dedizierte Link-Tabellen aus. Ein Beispiel: Ein „Kunde–Bestellung“-Link verbindet Kunden mit ihren Bestellungen, ohne die Hubs mit Beziehungsdaten zu belasten. Diese Trennung ermöglicht maximale Flexibilität, wenn sich Geschäftsbeziehungen ändern oder neue Beziehungstypen entstehen. Links können beliebig viele Hubs miteinander verbinden, wodurch sich komplexe n:m-Beziehungen leicht modellieren und pflegen lassen.

**Satellites** speichern alle beschreibenden Attribute und Kontextinformationen, die sich im Zeitverlauf ändern. Jeder Hub und jeder Link kann mehrere Satellites haben, die jeweils unterschiedliche Aspekte einer Entität zu verschiedenen Zeitpunkten erfassen. Ein Kunden-Hub könnte beispielsweise Satellites für demografische Daten, Präferenzen oder Bonitätsinformationen besitzen, die jeweils ihre eigene Änderungshistorie und Ladezyklen aufweisen. Diese feingranulare Trennung erlaubt eine präzise Historisierung und ermöglicht es Teams, unterschiedliche Attributgruppen unabhängig voneinander zu laden und zu aktualisieren.

Neben diesen Kernelementen gibt es im Data Vault auch sogenannte **abgeleitete Entitäten**, die spezifischere Geschäftsanforderungen adressieren – z. B. **Point-in-Time-Tabellen (PIT)** oder **Bridge-Tabellen**. Da diese fortgeschrittener sind, werden sie in diesem Blog nicht behandelt. Bei Fragen zu spezifischeren Entitäten können Sie sich jedoch jederzeit melden.

- Abbildung eines Beispiel-Hubs, Links und Satellites

------

## Die Schichtenarchitektur**

Data Vault 2.0 organisiert diese Modellierungskomponenten in einer **dreischichtigen Architektur**. Auch wenn Schichtenarchitekturen seit Bill Inmon ein Grundprinzip des Data Warehousing darstellen, ist die Data-Vault-2.0-Umsetzung insofern einzigartig, als dass sie in allen Schichten eine strukturelle Konsistenz beibehält. Andere Ansätze hingegen kombinieren oft verschiedene Modellierungsmethoden in den einzelnen Schichten (z. B. relational im Staging, normalisiert im Warehouse, dimensional in Marts).

In der **Staging-Schicht** landen alle eingehenden Rohdaten in ihrer ursprünglichen Form – mit minimalen Transformationen. Nur eine grundlegende Standardisierung sorgt dafür, dass das Laden ins Raw Vault konsistent möglich ist. Die Staging-Schicht dient als Puffer zwischen den Quellsystemen und den komplexeren Transformationsprozessen downstream. Zudem ermöglicht sie eine vollständige Nachvollziehbarkeit darüber, wann welche Daten aus welcher Quelle eingetroffen sind.

Das **Raw Vault** ist die markanteste Innovation von Data Vault. Anstatt Daten beim Laden zu normalisieren oder zu denormalisieren, speichert es die reinen, unveränderten Geschäftsdaten nach dem Hub-Link-Satellite-Prinzip. Diese Schicht dient als „Single Source of Truth“ für sämtliche historischen Daten. Sie gewährleistet vollständige Nachvollziehbarkeit und bewahrt die Daten so, wie die Quellsysteme sie erfasst haben – strukturiert für maximale Flexibilität und langfristige Historisierung. Geschäftsregeln oder Transformationen finden hier nicht statt.

Das **Business Vault** ergänzt das Raw Vault um berechnete Felder, Geschäftsregeln und abgeleitete Daten – jedoch unter Beibehaltung derselben Hub-Link-Satellite-Struktur. Damit bietet es dieselbe strenge Historisierung wie das Raw Vault, erweitert aber die Daten um Business-Logik für analytische Zwecke. Zusammen bilden Raw Vault und Business Vault die Kernschicht des Data-Vault-Warehouse, wobei die Unterscheidung eher funktional als architektonisch ist.

**Information Marts** bilden die letzte Schicht. Hier werden die Daten für spezifische analytische Anforderungen in optimierten Formaten bereitgestellt. Das können klassische dimensionale Modelle, spezialisierte Analysemodelle oder operative Datenspeicher sein. Sie basieren jedoch stets auf einem Fundament, das vollständige Datenherkunft und historischen Kontext garantiert.

- Abbildung der Data-Vault-Schichtenarchitektur

------

Nachdem wir nun die wichtigsten Konzepte von Data Vault 2.0 behandelt haben, werden wir im nächsten Beitrag ein Beispiel-Warehouse implementieren, um zu sehen, wie alles in der Praxis zusammenpasst. Bleiben Sie dran für den nächsten Blog – und zögern Sie nicht, bei Fragen oder Kommentaren Kontakt aufzunehmen. Bis bald!
