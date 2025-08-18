Data modeling sits at the heart of every modern Enterprise Data Warehouse (EDW), yet it is often neglected, leading to scalability bottlenecks and maintenance headaches as data volumes and update frequencies grow.

Data Vault delivers a unique architecture that combines scalability, full auditability, and resilient historical tracking of changes. Many practitioners, however, misunderstand its scope and underappreciate its true potential. Although the original Data Vault methodology emphasized modeling, Data Vault 2.0 extends far beyond that single layer. In their landmark book, Daniel Linstedt and Michael Olschimke present Data Vault 2.0 as a comprehensive “system of business intelligence,” complete with practical, enterprise-scale workflows for implementing not just the model but an end-to-end data management framework.

One of the main pillars of Data Vault is its methodology, which combines well-established enterprise practices. It uses the Capability Maturity Integration (CMMI) to help organizations gradually build maturity in their data management processes, ensuring they develop the right capabilities in the right order. Project Management Professional (PMP) principles ensure projects stay on track and deliver business value, while Systems Development Life Cycle (SDLC) provides a structured, repeatable approach to development.

Data Vault 2.0 also integrates Six Sigma and Total Quality Management (TQM) to embed a culture of quality and continuous improvement throughout the lifecycle, from design to operations. Last but not least, Scrum methodology brings agility to delivery, enabling teams to respond to changing business needs through short sprints, stakeholder collaboration, and iterative releases. A much more detailed discussion of the methodology can be found in the Data Vault 2.0 book.

- Pic of the methodology as shown in the DV2.0 book

---

## Fundamentals of Data Vault Modeling

Data Vault 2.0 builds upon three fundamental modeling constructs that form the backbone of its architecture. Understanding these components is crucial for appreciating how Data Vault achieves its balance of flexibility and performance. These main building blocks are: Hubs, Links, and Satellites.

**Hubs** represent the core business concepts within an organization. Fundamentally, what is it that a business tracks? Those will be the Hubs in a data vault. A Hub contains only the business key and metadata such as load timestamps and record sources. Think of Hubs as the stable anchors in the data model. Examples of a Hub might be: a customer Hub, product Hub, order Hub, etc. These entities rarely change their fundamental identity, making them perfect candidates for the Hub structure. The beauty of this design lies in its simplicity and stability. Regardless of how customer attributes evolve over time, the customer's business key remains constant.

The next core concept, **Links**, captures the relationships and business events between Hubs. Unlike traditional approaches, such as 3NF, that might embed foreign keys within entities, Data Vault isolates these relationships into dedicated Link tables. For example, a Customer-Order Link connects customers to their orders without cluttering either the Customer or Order Hub with relationship data. It might seem trivial at first sight, but this separation provides tremendous flexibility when business relationships change or when new relationship types emerge. Links can connect any number of Hubs, making complex many-to-many relationships straightforward to model and maintain.

**Satellites** house all the descriptive attributes and context that change over time. Every Hub and Link can have multiple Satellites attached, each capturing different aspects of the entity at different points in time. A Customer Hub might have separate Satellites for demographic information, preferences, credit ratings, and these Satellites could have their own change history and load patterns. This granular separation allows for precise historical tracking and enables team to load and update different attribute sets independently.

In addition to the core entities in Data Vault, there are also so-called derived entities that are used to address more specific business needs. These include, but are not limited to, Point-in-Time (PIT) tables and Bridge tables. We will not discuss these as they are more advanced entities and outside the scope of this blog.

- Picture of an example hub, link, and satellites

---

## The Layered Architecture

Data Vault 2.0 organizes these modeling components within a three-layer architecture, and while layered architectures have been fundamental to data warehousing since Bill Inmon, Data Vault 2.0 implementation is unique in that it maintains structural consistency across the different layers. This is as opposed to other methodologies that might, for example, use relational modeling in staging, normalized in the warehouse layer, and dimensional in marts.

In the **Staging Layer**, we have a landing zone for all incoming data. Raw data arrives here in its original form with minimal transformation. We have just enough standardization to ensure consistent loading into the Raw Vault. The Staging Layer acts as a buffer between the source systems and any sort complex transformation process that happens downstream. This way, we also have a complete audit trail of what arrived when and from where.

The **Raw Vault** represents Data Vault's most distinctive innovation. Instead of normalizing or denormalizing data upon entry to the warehouse, the Raw Vault preserves pure, untransformed business data organized into the Hub, Link, and Satellite structure. This layer serves as the single source of truth for all historical data, maintaining complete auditability while organizing information according to Data Vault modeling principles. No business rules or transformations are applied at this layer and it represents exactly what the business systems recorded, when they recorded it, but structured for maximum flexibility and historical preservation.

The **Business Vault** introduces calculated fields, business rules, and derived data while maintaining the same Hub, Link, Satellite. structure as the Raw Vault. It maintains the same rigorous historical tracking as the Raw Vault while adding the business intelligence needed for analytical workloads. The Raw Vault and Business Vault together form the core Data Vault warehouse layer, both using identical modeling structures. The distinction is functional rather than architectural.

**Information Marts** provide the final layer, delivering data in formats optimized for specific analytical use cases. These marts can be traditional dimensional models, specialized analytical structures, or operational data stores, but they draw from a foundation that preserves complete data lineage and historical context.

- Pic of the layered DV architecture

---

Now that we've covered the main concepts of Data Vault 2.0, we'll implement an example warehouse to see how everything fits together in practice. Stay tuned for the next blog, and don't hesitate to reach out with any questions or comments. See you soon!