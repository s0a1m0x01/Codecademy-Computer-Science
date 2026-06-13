-- ============================================================================
-- TASKS 1 - 3: EXPLORING DATA AND INDEX FOOTPRINTS
-- ============================================================================

-- 1. Get the total size of the table data on disk, excluding indexes
SELECT pg_size_pretty(pg_table_size('sensors.observations')) AS table_size_excluding_indexes;

-- 2. Inspect individual sizes of the known existing indexes to find the largest
SELECT 
  pg_size_pretty(pg_relation_size('observations_pkey')) AS primary_key_index_size,
  pg_size_pretty(pg_relation_size('observations_location_id_datetime_idx')) AS composite_index_size;

-- 3. Side-by-side comparison of data core size, cumulative index size, and total combined allocation
SELECT 
  pg_size_pretty(pg_table_size('sensors.observations')) AS table_data_size,
  pg_size_pretty(pg_indexes_size('sensors.observations')) AS total_index_size,
  pg_size_pretty(pg_total_relation_size('sensors.observations')) AS total_relation_size;


-- ============================================================================
-- TASKS 4 - 6: LARGE UPDATE AND REGULAR VACUUM BEHAVIOR
-- ============================================================================

-- 4. Execute large batch UPDATE to convert meters to feet
UPDATE sensors.observations 
SET distance_meters = distance_meters * 3.281;

-- 5. Check size after UPDATE to observe MVCC dead-tuple inflation (table bloat)
SELECT 
  pg_size_pretty(pg_table_size('sensors.observations')) AS table_data_size,
  pg_size_pretty(pg_total_relation_size('sensors.observations')) AS total_relation_size;

-- 6. Run a standard target vacuum to mark dead tuples as reusable for subsequent writes
VACUUM sensors.observations;

-- Verify the post-VACUUM table footprint size state
SELECT pg_size_pretty(pg_table_size('sensors.observations')) AS table_size_post_vacuum;


-- ============================================================================
-- TASKS 7 - 9: BULK INSERT AND VACUUM FULL OPTIMIZATION
-- ============================================================================

-- 7. Execute bulk import of secondary supplemental camera metadata tracking
\COPY sensors.observations (id, datetime, location_id, duration, distance_meters, category) FROM './additional_obs_types.csv' WITH DELIMITER ',' CSV HEADER;

-- 8. Verify size after bulk insert to see if PostgreSQL reused spaces cleared by VACUUM
SELECT pg_size_pretty(pg_table_size('sensors.observations')) AS table_size_post_insert;

-- 9. Run a VACUUM FULL to reclaim unused space and return it to the OS filesystem
VACUUM FULL sensors.observations;

-- Check final baseline footprint after full structural compaction
SELECT pg_size_pretty(pg_table_size('sensors.observations')) AS table_size_post_vacuum_full;


-- ============================================================================
-- TASKS 10 & 11: BATCH DELETE RECOVERY PROFILING
-- ============================================================================

-- 10. Perform large batch delete operation on out-of-bounds locations
DELETE FROM sensors.observations 
WHERE location_id > 24;

-- 11. Review storage usage to observe that DELETE leaves data files uncompacted
SELECT pg_size_pretty(pg_table_size('sensors.observations')) AS table_size_post_delete;


-- ============================================================================
-- TASKS 12 - 14: RELOADING THE TABLE VIA TRUNCATE COMPARISON
-- ============================================================================

-- 12. Instantaneously strip and reclaim all storage allocations via TRUNCATE
TRUNCATE sensors.observations RESTART IDENTITY;

-- 13. Reload the clean table with original and supplemental datasets sequentially
\COPY sensors.observations (id, datetime, location_id, duration, distance_meters, category) FROM './original_obs_types.csv' WITH DELIMITER ',' CSV HEADER;

\COPY sensors.observations (id, datetime, location_id, duration, distance_meters, category) FROM './additional_obs_types.csv' WITH DELIMITER ',' CSV HEADER;

-- 14. Gather definitive metrics on the freshly rewritten table for final verification
SELECT 
  pg_size_pretty(pg_table_size('sensors.observations')) AS clean_table_data_size,
  pg_size_pretty(pg_indexes_size('sensors.observations')) AS clean_total_index_size,
  pg_size_pretty(pg_total_relation_size('sensors.observations')) AS clean_total_relation_size;