-- ============================================================================
-- TASKS 1 & 2: EXISTING STRUCTURE EXPLORATION
-- ============================================================================

-- 1. Look at the first 10 rows in each table to understand the structure
SELECT * FROM customers LIMIT 10;
SELECT * FROM orders LIMIT 10;
SELECT * FROM books LIMIT 10;

-- 2. Examine the indexes that already exist on the tables
SELECT * FROM pg_indexes WHERE tablename IN ('customers', 'books', 'orders');


-- ============================================================================
-- TASK 3: CREATE INDEXES FOR FOREIGN KEYS
-- ============================================================================

-- Build single-column indexes on frequently queried foreign keys
CREATE INDEX orders_customer_id_idx ON orders (customer_id);
CREATE INDEX orders_book_id_idx ON orders (book_id);


-- ============================================================================
-- TASKS 4 & 5: PRE-INDEX PERFORMANCE & SIZE BASELINE
-- ============================================================================

-- 4. Check the runtime baseline using EXPLAIN ANALYZE
EXPLAIN ANALYZE 
SELECT original_language, title, sales_in_millions 
FROM books 
WHERE original_language = 'French';

-- 5. Get the total baseline size of the books table before adding the new index
SELECT pg_size_pretty(pg_total_relation_size('books'));


-- ============================================================================
-- TASKS 6 & 7: MULTICOLUMN INDEX ANALYSIS
-- ============================================================================

-- 6. Create a multicolumn index tailored to the translation team's query
CREATE INDEX books_lang_title_sales_idx ON books (original_language, title, sales_in_millions);

-- 7. Repeat baseline steps to compare runtime and size with the index active
EXPLAIN ANALYZE 
SELECT original_language, title, sales_in_millions 
FROM books 
WHERE original_language = 'French';

SELECT pg_size_pretty(pg_total_relation_size('books'));


-- ============================================================================
-- TASK 8: CLEAN UP MULTICOLUMN INDEX
-- ============================================================================

-- Delete the costly multicolumn index to optimize INSERT performance
DROP INDEX IF EXISTS books_lang_title_sales_idx;


-- ============================================================================
-- TASK 9: BULK INSERT WITH INITIAL INDEXES
-- ============================================================================

-- Measure bulk copy speed when table indexes are actively running
SELECT NOW();

\COPY orders FROM 'orders_add.txt' DELIMITER ',' CSV HEADER;

SELECT NOW();


-- ============================================================================
-- TASK 10: OPTIMIZED BULK INSERT (DROP -> COPY -> RECREATE)
-- ============================================================================

-- Drop indexes before bulk loading to eliminate real-time index-rebuilding overhead
DROP INDEX IF EXISTS orders_customer_id_idx;
DROP INDEX IF EXISTS orders_book_id_idx;

-- Run optimized copy command with timestamps
SELECT NOW();

\COPY orders FROM 'orders_add.txt' DELIMITER ',' CSV HEADER;

SELECT NOW();

-- Recreate the indexes cleanly after data loading is finished
CREATE INDEX orders_customer_id_idx ON orders (customer_id);
CREATE INDEX orders_book_id_idx ON orders (book_id);


-- ============================================================================
-- TASK 11: DESIGN AND TEST ALTERNATIVE CUSTOMER INDEX
-- ============================================================================

-- Instead of the proposed (first_name, email_address) index which violates 
-- the leftmost rule for primary email lookups, we create a highly optimized 
-- unique index directly on the email column.

-- Benchmark the baseline performance prior to adding the customer index
EXPLAIN ANALYZE 
SELECT * FROM customers 
WHERE email_address = 'test@example.com';

-- Implement the highly optimized unique single-column index
CREATE UNIQUE INDEX customers_email_address_idx ON customers (email_address);

-- Verify the performance boost (Ensures the planner switches to an Index Scan)
EXPLAIN ANALYZE 
SELECT * FROM customers 
WHERE email_address = 'test@example.com';