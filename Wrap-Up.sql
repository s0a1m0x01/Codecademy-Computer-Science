-- ============================================
-- EXAMPLE: Complete Database Security Setup
-- ============================================

-- 1. Create schemas
CREATE SCHEMA app_data;
CREATE SCHEMA reporting;
CREATE SCHEMA admin;

-- 2. Create group roles
CREATE ROLE app_user_group;
CREATE ROLE reporting_group;
CREATE ROLE admin_group;

-- 3. Create login roles
CREATE ROLE alice WITH LOGIN PASSWORD 'alice_pass';
CREATE ROLE bob WITH LOGIN PASSWORD 'bob_pass';
CREATE ROLE charlie WITH LOGIN PASSWORD 'charlie_pass';

-- 4. Assign group memberships
GRANT app_user_group TO alice;
GRANT app_user_group TO bob;
GRANT reporting_group TO charlie;
GRANT admin_group TO alice;  -- Alice is also an admin

-- 5. Set schema permissions
-- App users can use app_data schema
GRANT USAGE ON SCHEMA app_data TO app_user_group;
-- Reporting users can use reporting schema
GRANT USAGE ON SCHEMA reporting TO reporting_group;
-- Only admin group can modify admin schema
GRANT ALL ON SCHEMA admin TO admin_group;

-- 6. Set default privileges
-- Future tables in app_data: app users can read/write
ALTER DEFAULT PRIVILEGES IN SCHEMA app_data
GRANT SELECT, INSERT, UPDATE ON TABLES TO app_user_group;

-- Future tables in reporting: only SELECT for reporting group
ALTER DEFAULT PRIVILEGES IN SCHEMA reporting
GRANT SELECT ON TABLES TO reporting_group;

-- 7. Row Level Security example
CREATE TABLE app_data.sensitive_data (
    id SERIAL PRIMARY KEY,
    data TEXT,
    owner TEXT
);

ALTER TABLE app_data.sensitive_data ENABLE ROW LEVEL SECURITY;

CREATE POLICY user_owns_data ON app_data.sensitive_data
    USING (owner = current_user);

-- 8. Column Level Security example
-- Create a view that exposes only safe columns
CREATE VIEW reporting.safe_employee_data AS
SELECT id, name, department
FROM employees;

GRANT SELECT ON reporting.safe_employee_data TO reporting_group;

-- 9. Revoke dangerous default privileges
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON DATABASE mydb FROM PUBLIC;

-- 10. Audit queries
-- Check all roles
SELECT rolname, rolsuper, rolcanlogin, rolcreatedb
FROM pg_roles
WHERE rolname NOT LIKE 'pg_%'
ORDER BY rolname;

-- Check group memberships
SELECT 
    r.rolname AS member,
    g.rolname AS group_role
FROM pg_auth_members m
JOIN pg_roles r ON m.member = r.oid
JOIN pg_roles g ON m.roleid = g.oid;

-- Check table privileges
SELECT 
    grantee,
    table_schema,
    table_name,
    privilege_type
FROM information_schema.table_privileges
WHERE table_schema NOT IN ('information_schema', 'pg_catalog')
ORDER BY grantee, table_schema, table_name