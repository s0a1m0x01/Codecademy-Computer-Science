-- ============================================================================
-- STAGE 1 & 2: TOPIC SELECTION, RESEARCH & SCHEMA CREATION
-- ============================================================================
-- Business Context: A robust relational schema designed to track cybersecurity 
-- incidents, affected network assets, assigned analysts, and ingested SIEM alerts.
-- 
-- Entity-Relationship Architecture:
--   - analysts < orders/assigns > incidents (One-to-Many)
--   - assets < logs/impacts > incidents (Many-to-Many via junction table)
--   - incidents < maps to > alerts (One-to-Many)

-- Drop existing tables to ensure clean, repeatable execution state
DROP TABLE IF EXISTS incident_assets CASCADE;
DROP TABLE IF EXISTS alerts CASCADE;
DROP TABLE IF EXISTS incidents CASCADE;
DROP TABLE IF EXISTS assets CASCADE;
DROP TABLE IF EXISTS analysts CASCADE;

-- Create Analysts Master Catalog
CREATE TABLE analysts (
    analyst_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    clearance_level VARCHAR(20) DEFAULT 'Tier 1'
);

-- Create Assets Grid (Infrastructure Registry)
CREATE TABLE assets (
    asset_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    hostname VARCHAR(100) NOT NULL UNIQUE,
    ip_address INET NOT NULL,
    os_type VARCHAR(50) NOT NULL,
    criticality_score INT DEFAULT 5
);

-- Create Core Incident Response Table
CREATE TABLE incidents (
    incident_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_name VARCHAR(150) NOT NULL,
    severity VARCHAR(15) NOT NULL,
    status VARCHAR(20) DEFAULT 'Open',
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    closed_at TIMESTAMP WITHOUT TIME ZONE,
    analyst_id INT,
    summary TEXT
);

-- Create Junction Table for Many-to-Many mapping (Incidents <-> Affected Assets)
CREATE TABLE incident_assets (
    incident_id INT NOT NULL,
    asset_id INT NOT NULL,
    PRIMARY KEY (incident_id, asset_id)
);

-- Create SIEM Alerts Stream Table
CREATE TABLE alerts (
    alert_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    rule_name VARCHAR(150) NOT NULL,
    payload JSONB,
    ingested_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    incident_id INT
);


-- ============================================================================
-- STAGE 3: PROTECT YOUR DATABASE (CONSTRAINTS, INTEGRITY, & RBAC ROLES)
-- ============================================================================

-- 1. Enforce Domain Data Validation Constraints
ALTER TABLE assets 
    ADD CONSTRAINT chk_criticality CHECK (criticality_score BETWEEN 1 AND 10);

ALTER TABLE incidents 
    ADD CONSTRAINT chk_severity CHECK (severity IN ('Low', 'Medium', 'High', 'Critical')),
    ADD CONSTRAINT chk_status CHECK (status IN ('Open', 'In_Progress', 'Resolved', 'False_Positive'));

-- 2. Inject Relational Referential Integrity (Foreign Keys)
ALTER TABLE incidents 
    ADD CONSTRAINT fk_incident_analyst 
    FOREIGN KEY (analyst_id) REFERENCES analysts(analyst_id) ON DELETE SET NULL;

ALTER TABLE incident_assets 
    ADD CONSTRAINT fk_junction_incident 
    FOREIGN KEY (incident_id) REFERENCES incidents(incident_id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_junction_asset 
    FOREIGN KEY (asset_id) REFERENCES assets(asset_id) ON DELETE CASCADE;

ALTER TABLE alerts 
    ADD CONSTRAINT fk_alert_incident 
    FOREIGN KEY (incident_id) REFERENCES incidents(incident_id) ON DELETE SET NULL;

-- 3. Provision Role-Based Access Control (RBAC) Security Rings
-- Revoke default public privileges on schema modifications
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;

-- Create Read-Only Security Auditor Role
DROP ROLE IF EXISTS sec_auditor;
CREATE ROLE sec_auditor WITH LOGIN PASSWORD 'AuditorSecurePass2026!';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO sec_auditor;

-- Create Write-Allowed Incident Handler Role
DROP ROLE IF EXISTS soc_analyst_role;
CREATE ROLE soc_analyst_role WITH LOGIN PASSWORD 'AnalystResponse2026#';
GRANT SELECT, INSERT, UPDATE ON TABLE incidents, alerts, incident_assets TO soc_analyst_role;


-- ============================================================================
-- STAGE 4: POPULATE YOUR DATABASE WITH SYNTHETIC PRODUCTION DATA
-- ============================================================================

-- Populate Analysts
INSERT INTO analysts (first_name, last_name, email, clearance_level) VALUES
('Sohaim', 'Aslam', 's.aslam@soc.local', 'Tier 3'),
('Jane', 'Doe', 'j.doe@soc.local', 'Tier 1'),
('Alex', 'Smith', 'a.smith@soc.local', 'Tier 2');

-- Populate Assets Registry
INSERT INTO assets (hostname, ip_address, os_type, criticality_score) VALUES
('DC-01.corp.local', '10.0.0.4', 'Windows Server 2022', 10),
('APP-PROD-05', '10.0.1.50', 'Ubuntu 24.04 LTS', 8),
('FIN-DB-PRIMARY', '10.5.0.2', 'RHEL 9.4', 9),
('WORKSTATION-88', '192.168.4.88', 'Windows 11 Pro', 3);

-- Populate Incidents Records
INSERT INTO incidents (ticket_name, severity, status, analyst_id, summary) VALUES
('Suspicious LSASS Dump Attempt', 'Critical', 'In_Progress', 1, 'Credential dumping detected via native system tooling on Domain Controller.'),
('Outbound Beaconing to Known C2 IP', 'High', 'Open', 3, 'Internal host communicating with malicious external infrastructure.'),
('Brute Force Attack on SSH Port', 'Medium', 'Resolved', 2, 'External malicious automated scanner generating failed log-in anomalies.');

-- Populate Relational Mapping Junction Matrix
INSERT INTO incident_assets (incident_id, asset_id) VALUES
(1, 1), -- LSASS Dump impacted Domain Controller (DC-01)
(2, 4), -- Beaconing tracked to Workstation-88
(3, 2); -- SSH Brute Force hit App Server (APP-PROD-05)

-- Populate Correlated SIEM Alert Logs Document payloads
INSERT INTO alerts (rule_name, payload, incident_id) VALUES
('Windows Defender Threat Detection', '{"alert_type": "EDR", "technique": "T1003", "process": "lsass.exe"}', 1),
('Suricata Network Anomaly Trigger', '{"alert_type": "IDS", "destination_ip": "198.51.100.42", "packets": 412}', 2),
('Auth.log Failure Threshold Exceeded', '{"alert_type": "Syslog", "failed_attempts": 45, "port": 22}', 3);


-- ============================================================================
-- STAGE 5 & 6: OPTIMIZE YOUR DATABASE (INDEXES & 3NF NORMALIZATION DESIGN)
-- ============================================================================
-- Architectural Note: The database is built natively in Third Normal Form (3NF).
-- All attributes are atomic, independent, and dependent entirely upon the primary keys.
--
-- Optimization Rule: High-volume queries look up open alerts and unresolved incidents. 
-- We leverage composite, expression, and functional JSONB indices to bypass sequential scans.

-- 1. Index Foreign Keys to optimize system JOIN processing execution windows
CREATE INDEX incidents_analyst_id_idx ON incidents (analyst_id);
CREATE INDEX alerts_incident_id_idx ON alerts (incident_id);

-- 2. Partial Index for operational tracking tables (Saves space by ignoring closed tickets)
CREATE INDEX incidents_active_severe_idx ON incidents (severity, status) 
WHERE status IN ('Open', 'In_Progress');

-- 3. Advanced Expression Index evaluating deep fields nested inside JSONB unstructured payloads
CREATE INDEX alerts_payload_tech_idx ON alerts (((payload->>'technique')));

-- 4. Benchmarking Verification execution queries
EXPLAIN ANALYZE
SELECT * FROM incidents 
WHERE status = 'In_Progress' AND severity = 'Critical';

EXPLAIN ANALYZE
SELECT * FROM alerts 
WHERE payload->>'technique' = 'T1003';


-- ============================================================================
-- STAGE 7: ACTIVE RECOVERY AND COMPACTION MAINTENANCE
-- ============================================================================
-- Context: DML mutations generate internal MVCC ghost tuples. 
-- Regular routines optimize storage overhead without taking systems offline.

-- Analyze statistics engine tables to update query plan paths
ANALYZE incidents;
ANALYZE alerts;

-- Reclaim system dead space and structural allocation fragments safely back to OS
VACUUM FULL incident_assets;
VACUUM FULL alerts;

-- Final Storage Footprint Verification Health-Check Query
SELECT 
    relname AS table_name,
    pg_size_pretty(pg_table_size(pg_class.oid)) AS core_data_size,
    pg_size_pretty(pg_indexes_size(pg_class.oid)) AS total_index_size,
    pg_size_pretty(pg_total_relation_size(pg_class.oid)) AS cumulative_allocation
FROM pg_class
JOIN pg_namespace ON pg_namespace.oid = pg_class.relnamespace
WHERE nspname = 'public' AND relkind = 'r'
ORDER BY pg_total_relation_size(pg_class.oid) DESC;