-- ============================================
-- TASK 1: Find the superuser role name
-- ============================================

-- Query to find superuser roles
SELECT rolname 
FROM pg_roles 
WHERE rolsuper = true;

-- Alternative: Check all roles with their superuser status
SELECT rolname, rolsuper, rolcanlogin, rolcreatedb, rolcreaterole
FROM pg_roles
ORDER BY rolname;

-- ============================================
-- TASK 2: Find other users and their permissions
-- ============================================

-- Query to see all non-superuser roles and their permissions
SELECT 
    rolname,
    rolcanlogin AS can_login,
    rolcreatedb AS can_create_db,
    rolcreaterole AS can_create_role,
    rolinherit AS inherits_privileges
FROM pg_roles 
WHERE rolsuper = false
ORDER BY rolname;

-- ============================================
-- TASK 3: Check your current role
-- ============================================

-- Check current user/session role
SELECT current_user;

-- Check if current user is superuser
SELECT usesuper 
FROM pg_user 
WHERE usename = current_user;

-- Or using current_setting
SELECT current_setting('is_superuser');

-- ============================================
-- TASKS 4-5: Adding a Publisher
-- ============================================

-- Task 4: Create login role for ABC Open Data (no superuser)
CREATE ROLE abc_open_data WITH LOGIN PASSWORD 'abc_secure_password';

-- Verify the role was created
SELECT rolname, rolcanlogin, rolsuper 
FROM pg_roles 
WHERE rolname = 'abc_open_data';

-- Task 5: Create group role 'publishers' and add abc_open_data as member
CREATE ROLE publishers WITH NOLOGIN;

-- Add abc_open_data to publishers group
GRANT publishers TO abc_open_data;

-- Verify membership
SELECT 
    r.rolname AS member,
    g.rolname AS group_role
FROM pg_auth_members m
JOIN pg_roles r ON m.member = r.oid
JOIN pg_roles g ON m.roleid = g.oid
WHERE r.rolname = 'abc_open_data';

-- ============================================
-- TASKS 6-7: Granting Publisher Access to Analytics
-- ============================================

-- Task 6: Grant USAGE on analytics schema to publishers
GRANT USAGE ON SCHEMA analytics TO publishers;

-- Task 7: Grant SELECT on all existing tables in analytics to publishers
GRANT SELECT ON ALL TABLES IN SCHEMA analytics TO publishers;

-- Alternative: Grant SELECT on specific tables
-- GRANT SELECT ON analytics.downloads, analytics.views, analytics.users TO publishers;

-- Task 8: Check permissions in information_schema
-- Query to check if abc_open_data has SELECT on analytics.downloads
SELECT 
    grantee,
    table_schema,
    table_name,
    privilege_type
FROM information_schema.table_privileges
WHERE table_schema = 'analytics' 
    AND table_name = 'downloads'
    AND grantee IN ('abc_open_data', 'publishers')
ORDER BY grantee;

-- Expected: publishers will appear, abc_open_data inherits through publishers

-- Task 9: Test abc_open_data's ability to SELECT from analytics.downloads
-- Set role to abc_open_data
SET ROLE abc_open_data;

-- Test query (should work via inheritance from publishers)
SELECT * FROM analytics.downloads LIMIT 10;

-- Return to original superuser role
SET ROLE ccuser;  -- or RESET ROLE;

-- Verify you're back to original user
SELECT current_user;

-- ============================================
-- TASKS 10-12: Granting Publisher Access to Dataset Listings
-- ============================================

-- Task 10: Inspect directory.datasets table
SELECT * FROM directory.datasets LIMIT 5;

-- View table structure
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'directory' 
    AND table_name = 'datasets'
ORDER BY ordinal_position;

-- Task 11: Grant USAGE on directory schema to publishers
GRANT USAGE ON SCHEMA directory TO publishers;

-- Task 12: Grant SELECT on all columns EXCEPT data_checksum
-- Method 1: Grant on specific columns
GRANT SELECT (id, create_date, hosting_path, publisher, src_size) 
ON directory.datasets TO publishers;

-- Method 2: Grant SELECT on all columns then revoke on specific column
-- GRANT SELECT ON directory.datasets TO publishers;
-- REVOKE SELECT (data_checksum) ON directory.datasets FROM publishers;

-- Task 13: Test abc_open_data's access to directory.datasets
SET ROLE abc_open_data;

-- This query should FAIL because data_checksum is restricted
SELECT id, publisher, hosting_path, data_checksum 
FROM directory.datasets;

-- This query should SUCCEED (without data_checksum)
SELECT id, publisher, hosting_path 
FROM directory.datasets LIMIT 10;

-- Alternative: Include all allowed columns
SELECT id, create_date, hosting_path, publisher, src_size
FROM directory.datasets LIMIT 10;

-- Return to original role
SET ROLE ccuser;

-- ============================================
-- TASKS 14-15: Row Level Security on Downloads Data
-- ============================================

-- Task 14: Implement RLS on analytics.downloads
-- First, enable RLS on the table
ALTER TABLE analytics.downloads ENABLE ROW LEVEL SECURITY;

-- Create policy that restricts SELECT to the publisher of the dataset
-- Assumes analytics.downloads has a 'publisher' column
CREATE POLICY publisher_downloads_policy ON analytics.downloads
    FOR SELECT
    USING (publisher = current_user);

-- Alternative policy using a join to directory.datasets
-- CREATE POLICY publisher_downloads_policy ON analytics.downloads
--     FOR SELECT
--     USING (EXISTS (
--         SELECT 1 FROM directory.datasets d
--         WHERE d.id = analytics.downloads.dataset_id
--         AND d.publisher = current_user
--     ));

-- Verify RLS is enabled
SELECT 
    tablename,
    rls_enabled
FROM pg_tables
WHERE schemaname = 'analytics' AND tablename = 'downloads';

-- Task 15: Test RLS with different roles
-- Query as superuser/owner (should see all rows)
SELECT * FROM analytics.downloads LIMIT 10;

-- Switch to abc_open_data role
SET ROLE abc_open_data;

-- Query as publisher (should only see rows where publisher = 'abc_open_data')
SELECT * FROM analytics.downloads LIMIT 10;

-- Return to original role
SET ROLE ccuser;

-- ============================================
-- ADDITIONAL: Verification and Cleanup
-- ============================================

-- Check all current roles and their memberships
SELECT 
    r.rolname AS role_name,
    r.rolcanlogin AS can_login,
    r.rolsuper AS is_superuser,
    array_agg(g.rolname) AS member_of
FROM pg_roles r
LEFT JOIN pg_auth_members m ON r.oid = m.member
LEFT JOIN pg_roles g ON m.roleid = g.oid
WHERE r.rolname NOT LIKE 'pg_%'
GROUP BY r.rolname, r.rolcanlogin, r.rolsuper
ORDER BY r.rolname;

-- Check all policies on analytics.downloads
SELECT 
    policyname,
    tablename,
    cmd,
    roles,
    qual
FROM pg_policies
WHERE tablename = 'downloads';

-- Check current privileges on directory.datasets
SELECT 
    grantee,
    column_name,
    privilege_type
FROM information_schema.column_privileges
WHERE table_schema = 'directory' 
    AND table_name = 'datasets'
ORDER BY grantee, column_name;

-- Optional: Clean up if needed (for re-running the project)
-- DROP ROLE IF EXISTS abc_open_data;
-- DROP ROLE IF EXISTS publishers;
-- DROP POLICY IF EXISTS publisher_downloads_policy ON analytics.downloads;
-- ALTER TABLE analytics.downloads DISABLE ROW LEVEL SECURITY;