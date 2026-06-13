-- ============================================================================
-- TASKS 1 & 2: EXISTING STRUCTURE & INDEX EXAMINATION
-- ============================================================================

-- 1. Inspect the first 10 rows of each table to understand schema and data types
SELECT * FROM customers LIMIT 10;
SELECT * FROM orders LIMIT 10;
SELECT * FROM books LIMIT 10;

-- 2. Examine existing indexes across all three tables
SELECT * FROM pg_indexes WHERE tablename IN ('customers', 'books', 'orders');


-- ============================================================================
-- TASKS 3, 4 & 5: PARTIAL INDEX ANALYSIS
-- ============================================================================

-- 3. Baseline performance test for high-quantity marketing queries without index
EXPLAIN ANALYZE 
SELECT customer_id, quantity 
FROM orders 
WHERE quantity > 18;

-- 4. Build a Partial Index optimized specifically for quantities greater than 18
CREATE INDEX orders_high_quantity_p_idx ON orders (quantity) 
WHERE quantity > 18;

-- 5. Verify the partial index performance enhancement
EXPLAIN ANALYZE 
SELECT customer_id, quantity 
FROM orders 
WHERE quantity > 18;


-- ============================================================================
-- TASKS 6 & 7: PRIMARY KEY CREATION & CLUSTERING
-- ============================================================================

-- 6a. Baseline query benchmarking lookups on the unindexed customer_id field
EXPLAIN ANALYZE 
SELECT * FROM customers 
WHERE customer_id = 50;

-- 6b. Inject the primary key constraint (which generates the underlying B-Tree index)
ALTER TABLE customers ADD PRIMARY KEY (customer_id);

-- 6c. Verify performance boost on the primary key lookup field
EXPLAIN ANALYZE 
SELECT * FROM customers 
WHERE customer_id = 50;

-- 7. Cluster the table physically on disk matching the new primary key alignment
CLUSTER customers USING customers_pkey;

-- Check the first 10 rows again to verify physical sequencing on disk
SELECT * FROM customers LIMIT 10;


-- ============================================================================
-- TASKS 8 & 9: MULTICOLUMN INDEX & INDEX INCLUDING (COVERING)
-- ============================================================================

-- 8. Build a standard multicolumn index on frequently hit query criteria
CREATE INDEX orders_cust_book_idx ON orders (customer_id, book_id);

-- 9a. Drop the standard composite index to upgrade it for covering behavior
DROP INDEX IF EXISTS orders_cust_book_idx;

-- 9b. Recreate as a Covering Index using the INCLUDE clause to avoid secondary heap lookups
CREATE INDEX orders_cust_book_qty_idx ON orders (customer_id, book_id) INCLUDE (quantity);


-- ============================================================================
-- TASK 10: COMBINING INDEXES (COMPOSITE SEARCH OVERVIEW)
-- ============================================================================

-- Create a composite index to optimize the combined Author and Title site-search page
CREATE INDEX books_author_title_idx ON books (author, title);


-- ============================================================================
-- TASKS 11, 12 & 13: EXPRESSION (FUNCTION-BASED) INDEXES
-- ============================================================================

-- 11. Baseline performance check computing runtime calculated fields dynamically
EXPLAIN ANALYZE 
SELECT * FROM orders 
WHERE (quantity * price_base) > 100;

-- 12. Create an Expression Index to cache calculated total order valuations
CREATE INDEX orders_total_price_idx ON orders ((quantity * price_base));

-- 13. Verify that the planner leverages the expression index over a sequential scan
EXPLAIN ANALYZE 
SELECT * FROM orders 
WHERE (quantity * price_base) > 100;


-- ============================================================================
-- TASK 14: CLEANUP & APPLICATION OF COMPLEMENTARY STRATEGIES
-- ============================================================================

-- To clean up residual components or safely verify overall application state,
-- ensure everything is stable and check current overall footprint.
SELECT pg_size_pretty(pg_total_relation_size('orders')) AS orders_total_size;