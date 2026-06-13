-- ============================================================================
-- TASKS 1 - 4: INSPECT THE UNNORMALIZED MONOLITHIC 'STORE' DATA
-- ============================================================================

-- 1. Inspect the first 10 rows and all columns to understand the non-normalized schema
SELECT * FROM store LIMIT 10;

-- 2. Count distinct orders vs. distinct customers to detect duplication patterns
SELECT COUNT(DISTINCT(order_id)) FROM store;
SELECT COUNT(DISTINCT(customer_id)) FROM store;

-- 3. Review repeated customer profiles across multiple transaction entries
SELECT customer_id, customer_email, customer_phone 
FROM store 
WHERE customer_id = 1;

-- 4. Review repeated item properties across different historical orders
SELECT item_1_id, item_1_name, item_1_price 
FROM store 
WHERE item_1_id = 4;


-- ============================================================================
-- TASKS 5 - 13: SCHEMA DESIGN & TARGETED TABLE NORMALIZATION
-- ============================================================================

-- 5. Create the normalized 'customers' catalog extraction
CREATE TABLE customers AS 
SELECT DISTINCT customer_id, customer_email, customer_phone 
FROM store;

-- 6. Enforce Primary Key constraint on the new customers catalog
ALTER TABLE customers ADD PRIMARY KEY (customer_id);

-- 7. Normalize inventory records by extracting item properties from across slots
CREATE TABLE items AS 
SELECT DISTINCT item_1_id AS item_id, item_1_name AS name, item_1_price AS price FROM store WHERE item_1_id IS NOT NULL
UNION
SELECT DISTINCT item_2_id AS item_id, item_2_name AS name, item_2_price AS price FROM store WHERE item_2_id IS NOT NULL
UNION
SELECT DISTINCT item_3_id AS item_id, item_3_name AS name, item_3_price AS price FROM store WHERE item_3_id IS NOT NULL;

-- 8. Enforce Primary Key constraint on the new items table
ALTER TABLE items ADD PRIMARY KEY (item_id);

-- 9. Construct the Many-to-Many junction table linking orders to items
CREATE TABLE orders_items AS
SELECT order_id, item_1_id AS item_id FROM store WHERE item_1_id IS NOT NULL
UNION ALL
SELECT order_id, item_2_id AS item_id FROM store WHERE item_2_id IS NOT NULL
UNION ALL
SELECT order_id, item_3_id AS item_id FROM store WHERE item_3_id IS NOT NULL;

-- 10. Extract the base order metadata without item descriptions or duplicated client properties
CREATE TABLE orders AS
SELECT DISTINCT order_id, order_date, customer_id 
FROM store;

-- 11. Enforce Primary Key constraint on the clean orders master table
ALTER TABLE orders ADD PRIMARY KEY (order_id);

-- 12. Establish Referential Integrity from orders back to the customer profile
ALTER TABLE orders 
ADD FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

-- Establish Referential Integrity from junction table back to item records
ALTER TABLE orders_items 
ADD FOREIGN KEY (item_id) REFERENCES items(item_id);

-- 13. Secure final Referential Integrity constraint linking items back to their parent order entries
ALTER TABLE orders_items 
ADD FOREIGN KEY (order_id) REFERENCES orders(order_id);


-- ============================================================================
-- TASKS 14 - 18: COMPREHENSIVE QUERY BENCHMARKING (OLD VS NEW)
-- ============================================================================

-- 14. Old Database: Query customer contact lists for recent orders
SELECT customer_email 
FROM store 
WHERE order_date > '2019-07-25';

-- 15. Normalized Database: Query customer contact lists for recent orders via clean joins
SELECT c.customer_email 
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_date > '2019-07-25';

-- 16. Old Database: Aggregate item popularity volumes using complex recursive stacking
WITH aggregated_items AS (
  SELECT item_1_id AS item_id FROM store
  UNION ALL
  SELECT item_2_id AS item_id FROM store
  UNION ALL
  SELECT item_3_id AS item_id FROM store
)
SELECT item_id, COUNT(*) 
FROM aggregated_items 
WHERE item_id IS NOT NULL 
GROUP BY item_id;

-- 17. Normalized Database: Query item sales volumes cleanly from the relational junction matrix
SELECT item_id, COUNT(order_id) AS order_count 
FROM orders_items 
GROUP BY item_id;

-- 18. Analytics Reflection & Assessment
-- queries targeting direct entity metrics (e.g. total volume sales per item catalog) 
-- are drastically simpler and scale cleaner without storage bloat.