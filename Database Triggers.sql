-- ============================================
-- TASK 1: Familiarize with existing structure
-- ============================================

-- View customers table ordered by customer_id
SELECT * FROM customers 
ORDER BY customer_id;

-- View customers_log table
SELECT * FROM customers_log 
ORDER BY log_id;

-- ============================================
-- TASKS 2-4: UPDATE TRIGGER
-- ============================================

-- Task 2: Create trigger for UPDATE on customers
-- This trigger fires when first_name or last_name is updated
CREATE TRIGGER customer_update 
AFTER UPDATE OF first_name, last_name ON customers
BEGIN
    INSERT INTO customers_log (
        customer_id,
        change_type,
        changed_by,
        changed_at,
        old_first_name,
        old_last_name,
        new_first_name,
        new_last_name
    ) VALUES (
        OLD.customer_id,
        'UPDATE',
        CURRENT_USER,
        DATETIME('now'),
        OLD.first_name,
        OLD.last_name,
        NEW.first_name,
        NEW.last_name
    );
END;

-- Task 3: Test UPDATE trigger (modify first_name)
-- This should create a log entry
UPDATE customers 
SET first_name = 'Johnathan' 
WHERE customer_id = 1;

-- Verify trigger worked - check customers_log
SELECT * FROM customers_log ORDER BY log_id;

-- Task 4: Test when trigger should NOT fire (modifying other column)
-- This should NOT create a log entry
UPDATE customers 
SET years_old = 35 
WHERE customer_id = 1;

-- Verify no new log entry for this change
SELECT * FROM customers_log ORDER BY log_id;

-- ============================================
-- TASKS 5-6: INSERT TRIGGER
-- ============================================

-- Task 5: Create trigger for INSERT on customers
-- This fires once per statement, not per row
CREATE TRIGGER customer_insert 
AFTER INSERT ON customers
BEGIN
    INSERT INTO customers_log (
        change_type,
        changed_by,
        changed_at,
        num_rows_affected
    ) VALUES (
        'INSERT',
        CURRENT_USER,
        DATETIME('now'),
        (SELECT COUNT(*) FROM inserted)
    );
END;

-- Task 6: Test INSERT trigger with multiple rows
-- Add three customers in one statement
INSERT INTO customers (first_name, last_name, email, phone, city, state, years_old) VALUES
    ('Jeffrey', 'Cook', 'jeffrey.cook@example.com', '202-555-0398', 'Jersey City', 'New Jersey', 66),
    ('Maria', 'Garcia', 'maria.garcia@example.com', '303-555-0123', 'Denver', 'Colorado', 28),
    ('David', 'Kim', 'david.kim@example.com', '415-555-0456', 'San Francisco', 'California', 42);

-- Verify customers table
SELECT * FROM customers ORDER BY customer_id;

-- Verify customers_log - should have only ONE insert log entry
SELECT * FROM customers_log ORDER BY log_id;

-- ============================================
-- TASKS 7-9: CONDITIONAL TRIGGER (Age constraint)
-- ============================================

-- Task 7: Create trigger to enforce minimum age (13)
-- This uses BEFORE UPDATE to override changes
CREATE TRIGGER customer_min_age 
BEFORE UPDATE OF years_old ON customers
WHEN NEW.years_old < 13
BEGIN
    UPDATE customers 
    SET years_old = 13 
    WHERE customer_id = NEW.customer_id;
END;

-- Task 8: Test conditional trigger
-- Update customer to age 10 (should be changed to 13)
UPDATE customers 
SET years_old = 10 
WHERE customer_id = 2;

-- Update customer to age 25 (should remain 25)
UPDATE customers 
SET years_old = 25 
WHERE customer_id = 3;

-- Check results - age 10 should become 13, age 25 should stay 25
SELECT customer_id, first_name, last_name, years_old 
FROM customers 
ORDER BY customer_id;

-- Check log entries
SELECT * FROM customers_log ORDER BY log_id;

-- Task 9: Test multiple column update
-- Update first_name and years_old in same query
UPDATE customers 
SET first_name = 'Jeffrey Jr.', years_old = 5 
WHERE customer_id = 4;

-- Check results
SELECT customer_id, first_name, last_name, years_old 
FROM customers 
ORDER BY customer_id;

-- Check log entries
SELECT * FROM customers_log ORDER BY log_id;

-- ============================================
-- TASKS 10-11: TRIGGER CLEANUP
-- ============================================

-- Task 10: Remove the age constraint trigger
DROP TRIGGER IF EXISTS customer_min_age;

-- Task 11: Verify triggers on the system
-- List all triggers
SELECT name, tbl_name, sql 
FROM sqlite_master 
WHERE type = 'trigger';

-- Alternative: Show all triggers with details
SELECT 
    name AS trigger_name,
    tbl_name AS table_name,
    sql AS trigger_code
FROM sqlite_master 
WHERE type = 'trigger'
ORDER BY name;

-- ============================================
-- TASK 12: ADDITIONAL PRACTICE
-- ============================================

-- Create a trigger for DELETE operations
CREATE TRIGGER customer_delete 
AFTER DELETE ON customers
BEGIN
    INSERT INTO customers_log (
        customer_id,
        change_type,
        changed_by,
        changed_at,
        old_first_name,
        old_last_name
    ) VALUES (
        OLD.customer_id,
        'DELETE',
        CURRENT_USER,
        DATETIME('now'),
        OLD.first_name,
        OLD.last_name
    );
END;

-- Test DELETE trigger
DELETE FROM customers WHERE customer_id = 3;

-- Verify DELETE was logged
SELECT * FROM customers_log ORDER BY log_id;

-- Create a trigger that prevents deletion of senior customers
CREATE TRIGGER prevent_senior_deletion 
BEFORE DELETE ON customers
WHEN OLD.years_old > 65
BEGIN
    SELECT RAISE(ABORT, 'Cannot delete customers over 65 years old');
END;

-- Test the prevention trigger (should raise error)
-- DELETE FROM customers WHERE customer_id = 1;

-- Create a trigger that logs all changes to a summary table
CREATE TABLE IF NOT EXISTS change_summary (
    summary_id INTEGER PRIMARY KEY,
    change_date DATE,
    change_type TEXT,
    total_changes INTEGER
);

CREATE TRIGGER log_change_summary 
AFTER INSERT ON customers_log
BEGIN
    INSERT OR REPLACE INTO change_summary (change_date, change_type, total_changes)
    VALUES (
        DATE('now'),
        NEW.change_type,
        COALESCE((SELECT total_changes + 1 FROM change_summary WHERE change_date = DATE('now') AND change_type = NEW.change_type), 1)
    );
END;

-- Clean up all custom triggers (if needed)
-- DROP TRIGGER IF EXISTS customer_update;
-- DROP TRIGGER IF EXISTS customer_insert;
-- DROP TRIGGER IF EXISTS customer_delete;
-- DROP TRIGGER IF EXISTS prevent_senior_deletion;
-- DROP TRIGGER IF EXISTS log_change_summary;