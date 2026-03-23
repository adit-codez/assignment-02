# Design Justification

## Storage Systems

Each of the four system goals requires a storage system chosen to match its data access patterns, volume, and latency requirements.

**Goal 1 — Predict patient readmission risk** uses a **relational database (PostgreSQL)**. Patient records, diagnoses, medications, and treatment histories are structured, tabular data with well-defined relationships. A relational database enforces schema integrity, supports complex JOIN queries across tables (e.g., linking patients to admissions to diagnoses), and integrates cleanly with ML pipelines through standard SQL exports or ORM connectors. Historical treatment data changes infrequently and is read-heavy during model training, which suits a relational store well.

**Goal 2 — Allow doctors to query patient history in plain English** uses a **vector store (e.g., Pinecone or pgvector)**. Natural language queries are converted into embeddings by an NLP model, and the vector store enables semantic similarity search over patient history embeddings. Unlike keyword search, this approach handles synonyms, paraphrasing, and medical shorthand — for example, matching "cardiac event" to records containing "myocardial infarction." The vector store works alongside the relational database: the NLP engine retrieves relevant record IDs semantically, then fetches full details from the relational store.

**Goal 3 — Generate monthly reports** uses a **data warehouse (e.g., Amazon Redshift or BigQuery)**. Monthly reporting involves aggregating large volumes of historical data — bed occupancy rates, department-wise costs, patient throughput — across long time ranges. A data warehouse is optimised for these OLAP (Online Analytical Processing) workloads, supporting columnar storage, efficient GROUP BY and aggregation queries, and scheduled ETL pipelines that pull data from the relational database nightly.

**Goal 4 — Stream and store real-time vitals from ICU devices** uses a **time-series database (e.g., InfluxDB or TimescaleDB)**. Vitals data (heart rate, blood pressure, SpO2) is a continuous, high-frequency stream indexed by timestamp. Time-series databases are purpose-built for this: they compress sequential data efficiently, support fast range queries ("show me heart rate over the last 4 hours"), and offer built-in downsampling and retention policies to manage storage at scale.

## OLTP vs OLAP Boundary

The transactional system ends at the relational database. All writes from the EHR system, doctor portal, and admin system flow into PostgreSQL via standard OLTP operations — individual row inserts and updates in real time. The analytical system begins at the data warehouse. A nightly ETL job extracts, transforms, and loads aggregated data from PostgreSQL into the warehouse, where it becomes available for read-heavy reporting queries. This separation ensures that long-running analytics queries never compete with or degrade the performance of live clinical record updates.

## Trade-offs

The most significant trade-off is **data freshness vs. system complexity**. By separating the relational database (OLTP) from the data warehouse (OLAP) with a nightly ETL pipeline, monthly reports may reflect data that is up to 24 hours stale. For administrative reporting this is acceptable, but it means the ML readmission model trained on warehouse data could lag behind very recent patient events.

**Mitigation:** Implement a streaming ETL layer (e.g., Apache Kafka with a Kafka Connect sink to the warehouse) that propagates critical record changes in near real time — reducing the lag from 24 hours to minutes — while still keeping the OLTP and OLAP systems architecturally separate. For the ML model specifically, a scheduled retraining pipeline triggered every few hours (rather than daily) would further reduce prediction lag without requiring a full system redesign.
