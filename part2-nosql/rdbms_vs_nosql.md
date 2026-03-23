# RDBMS vs NoSQL

---

## Database Recommendation

**Scenario:** A healthcare startup is building a patient management system. One engineer recommends MySQL; another recommends MongoDB. Given ACID vs BASE and the CAP theorem, which would you recommend, and would your answer change if a fraud detection module were added?

---

For a **patient management system**, I would recommend **MySQL (RDBMS)** as the primary database.

Healthcare data is among the most sensitive and legally regulated data in existence. Patient records involve structured, highly relational data — patients linked to diagnoses, diagnoses linked to prescriptions, prescriptions linked to doctors, billing linked to insurance. This relational structure is a natural fit for a schema-enforced, tabular database like MySQL.

The most critical reason is **ACID compliance**. In healthcare, every transaction must be atomic and consistent. Consider a scenario where a doctor updates a patient's medication: if the write to the prescriptions table succeeds but the update to the patient's active medications fails halfway, the patient could receive the wrong drug or dosage. ACID guarantees that either the entire transaction completes or none of it does — there is no partial state. This is non-negotiable in a medical context.

From a **CAP theorem** perspective, MySQL prioritizes **Consistency and Partition Tolerance** over availability. This is the correct trade-off for healthcare — it is far better for the system to be temporarily unavailable than to serve stale or inconsistent medical records.

MongoDB, while flexible and scalable, follows the **BASE** model (Basically Available, Soft state, Eventually consistent). Eventual consistency is unacceptable when a nurse reads a patient's allergy record — it must always reflect the latest confirmed data.

**If a fraud detection module is added**, the recommendation would **partially change**. Fraud detection requires analyzing large volumes of transactional events rapidly, often using graph relationships or pattern matching across millions of records. For this specific module, a **NoSQL or graph database** (such as MongoDB or Neo4j) would complement MySQL well — handling high-throughput event streams and anomaly detection while the core patient records remain safely in MySQL.

In summary: **MySQL for the core patient system; MongoDB or a graph DB as a supplementary layer for fraud detection.** A polyglot persistence architecture is the most pragmatic solution.

---

