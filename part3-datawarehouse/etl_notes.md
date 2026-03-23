## ETL Decisions

### Decision 1 — Standardizing Inconsistent Category Casing

Problem: The `category` column contained the same category spelled in multiple inconsistent ways across the 300 rows. Specifically, `Electronics` appeared as both `"Electronics"` (60 rows) and `"electronics"` (41 rows) in lowercase. Similarly, `Groceries` appeared as both `"Groceries"` (40 rows) and `"Grocery"` (87 rows) — two different names for the same category. This inconsistency would cause GROUP BY queries to treat them as separate categories, producing incorrect revenue totals and wrong analytical results.

Resolution: During the transformation step, all category values were standardized to Title Case using `.str.strip().str.title()` and then `"Grocery"` was explicitly mapped to `"Groceries"` to unify the naming. The cleaned, canonical values loaded into `dim_product` are: `Electronics`, `Clothing`, and `Groceries`.

---

### Decision 2 — Filling NULL Values in store_city

Problem: The `store_city` column contained 19 NULL values spread across all 5 stores (`Chennai Anna`, `Delhi South`, `Bangalore MG`, `Pune FC Road`, `Mumbai Central`). These NULLs would have been loaded into `dim_store` as missing data, making city-level reporting impossible and potentially causing JOIN failures in analytical queries that filter or group by city.

Resolution: Since `store_name` and `store_city` have a fixed one-to-one relationship (each store always belongs to one city), a lookup mapping was applied during transformation to fill in the missing city values based on the store name. For example, all rows with `store_name = "Mumbai Central"` and a NULL city were filled with `"Mumbai"`. This ensured every row in `dim_store` has a complete, valid `store_city`.

---

### Decision 3 — Computing total_amount as a Derived Measure in the Fact Table

Problem: The raw data only provided `units_sold` and `unit_price` as separate columns. There was no pre-calculated total transaction value. Loading raw data without a total amount column would require every analytical query (revenue by store, revenue by category, month-over-month trend) to repeat the multiplication `units_sold * unit_price` inline, making queries verbose and prone to inconsistency if the formula is applied differently across queries.

Resolution: A derived column `total_amount` was computed during the transformation step as `units_sold × unit_price` and stored directly in the `fact_sales` table. This follows standard data warehousing practice of pre-computing common measures at load time so that all analytical queries can simply use `SUM(total_amount)` without recalculating it each time.
