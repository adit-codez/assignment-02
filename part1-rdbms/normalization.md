# Normalization Report — orders_flat.csv

---

## Anomaly Analysis

The flat file `orders_flat.csv` stores all information (customer, product, sales rep, and order details) in a single table with 15 columns and 186 rows. This denormalized structure leads to the following anomalies:

---

### Insert Anomaly

**Definition:** A new record cannot be inserted without providing unrelated data.

**Example from data:**  
Suppose a new sales representative `SR04 - Meera Pillai` is hired and assigned to the Hyderabad office. In the flat file, her details (`sales_rep_id`, `sales_rep_name`, `sales_rep_email`, `office_address`) **cannot be recorded** until she is associated with at least one order. There is no way to store a sales rep independently — the rep's information is tied to the `order_id`.

Similarly, a new product (e.g., `P009 - Whiteboard`) cannot be added to the system until at least one order is placed for it.

**Affected columns:** `sales_rep_id`, `sales_rep_name`, `sales_rep_email`, `office_address`, `product_id`, `product_name`, `category`, `unit_price`

---

### Update Anomaly

**Definition:** Updating one piece of information requires updating multiple rows, risking inconsistency.

**Example from data:**  
Sales rep `SR01 - Deepak Joshi` has **two different office addresses** recorded across rows:

| order_id | sales_rep_id | office_address |
|----------|-------------|----------------|
| ORD1114  | SR01        | Mumbai HQ, Nariman Point, Mumbai - 400021 |
| ORD1180  | SR01        | Mumbai HQ, Nariman Pt, Mumbai - 400021 |

Because Deepak's address is repeated in every row where he is the sales rep (50+ rows), an address change must be applied to **all those rows**. If even one row is missed, the data becomes inconsistent — which is exactly what happened here ("Nariman Point" vs "Nariman Pt").

**Affected columns:** `sales_rep_name`, `sales_rep_email`, `office_address`, `customer_name`, `customer_email`, `product_name`, `category`, `unit_price`

---

### Delete Anomaly

**Definition:** Deleting a record unintentionally destroys other unrelated information.

**Example from data:**  
Product `P008 - Webcam` (Electronics, ₹2100) appears in **only one order**: `ORD1185` (customer C003, Amit Verma, quantity 1).

| order_id | customer_id | product_id | product_name | category    | unit_price |
|----------|-------------|------------|--------------|-------------|------------|
| ORD1185  | C003        | P008       | Webcam       | Electronics | 2100       |

If order `ORD1185` is deleted (e.g., because the order was cancelled), **all information about the Webcam product is permanently lost** from the database — its name, category, and price — even though the intent was only to cancel an order.

**Affected columns:** `product_id`, `product_name`, `category`, `unit_price`

---

## Normalization to Third Normal Form (3NF)

### First Normal Form (1NF)
The flat file already satisfies 1NF — each cell holds a single atomic value and there are no repeating groups.

### Second Normal Form (2NF)
To achieve 2NF, we must eliminate **partial dependencies** (non-key attributes that depend on only part of a composite key).

In the flat file, the implied key is `(order_id, product_id)`. However:
- `customer_name`, `customer_email`, `customer_city` depend only on `customer_id` (not the full key)
- `product_name`, `category`, `unit_price` depend only on `product_id`
- `sales_rep_name`, `sales_rep_email`, `office_address` depend only on `sales_rep_id`

These are extracted into separate tables.

### Third Normal Form (3NF)
To achieve 3NF, we eliminate **transitive dependencies** (non-key attribute → non-key attribute).

In the flat file:
- `sales_rep_name` and `sales_rep_email` are transitively dependent via `sales_rep_id`
- `product_name` and `category` are transitively dependent via `product_id`
- `customer_name` and `customer_email` are transitively dependent via `customer_id`

All transitive dependencies are resolved by the decomposition below.

---

## Final 3NF Schema

The flat file is decomposed into **4 tables**:

| Table | Primary Key | Description |
|-------|-------------|-------------|
| `customers` | `customer_id` | Customer master data |
| `products` | `product_id` | Product catalog |
| `sales_reps` | `sales_rep_id` | Sales representative data |
| `orders` | `order_id` | Order transactions |

### How anomalies are resolved:
- **Insert Anomaly** → A new product or sales rep can be inserted into their own table without needing an order.
- **Update Anomaly** → Deepak Joshi's office address is stored in exactly **one row** in `sales_reps`. Updating it once is sufficient.
- **Delete Anomaly** → Deleting order `ORD1185` only removes the order row. Product `P008 - Webcam` remains safely in the `products` table.
