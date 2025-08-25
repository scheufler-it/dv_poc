- sources
- stage + route surrogate key
- vault layer (raw vault + business vault)
- information layer
- documentation

---

1. Data Vault 2.0 Overview
1. Layer 1: Staging
   - source definitions
   - staging transformations
1. Layer 2: Raw Vault (+ Business Vault not implemented)
   - Hubs, Links, Satellites
   - Example SQL models
1. Layer 3: Information Marts
   - Analytical models
1. dbt Features Used
   - Macros (generate_schema_name.sql)
   - Packages (dbt_packages/datavault4dbt)
1. Conclusions