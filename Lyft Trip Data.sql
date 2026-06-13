-- ============================================
-- TASK 1: EXAMINE TABLES
-- ============================================

-- View all data
SELECT * FROM trips;
SELECT * FROM riders;
SELECT * FROM cars;

-- View table structures (column names and data types)
PRAGMA table_info(trips);
PRAGMA table_info(riders);
PRAGMA table_info(cars);

-- ============================================
-- TASK 2: PRIMARY KEYS
-- ============================================

-- Primary key identification:
-- trips.id is the primary key of trips
-- riders.id is the primary key of riders  
-- cars.id is the primary key of cars

-- Alternative: Query to see table schemas
SELECT 
    'trips' AS table_name,
    name AS column_name,
    CASE WHEN pk > 0 THEN 'PRIMARY KEY' ELSE '' END AS key_type
FROM pragma_table_info('trips')
UNION ALL
SELECT 
    'riders', name,
    CASE WHEN pk > 0 THEN 'PRIMARY KEY' ELSE '' END
FROM pragma_table_info('riders')
UNION ALL
SELECT 
    'cars', name,
    CASE WHEN pk > 0 THEN 'PRIMARY KEY' ELSE '' END
FROM pragma_table_info('cars');

-- ============================================
-- TASK 3: CROSS JOIN
-- ============================================

-- Simple cross join (every rider with every car)
SELECT riders.first_name, riders.last_name, cars.model, cars.color
FROM riders
CROSS JOIN cars;

-- Is the result useful?
-- Not very useful for analysis - creates many rows with no logical relationship.
-- Each rider is paired with every car regardless of actual trips.

-- ============================================
-- TASK 4: LEFT JOIN (trips and riders)
-- ============================================

-- Basic LEFT JOIN
SELECT 
    trips.id AS trip_id,
    trips.date,
    trips.cost,
    riders.id AS rider_id,
    riders.first_name,
    riders.last_name,
    riders.total_trips
FROM trips
LEFT JOIN riders ON trips.rider_id = riders.id
ORDER BY trips.date DESC;

-- LEFT JOIN with filtering (only trips that have matching riders)
SELECT *
FROM trips
LEFT JOIN riders ON trips.rider_id = riders.id
WHERE riders.id IS NOT NULL;

-- ============================================
-- TASK 5: INNER JOIN (trips and cars)
-- ============================================

-- Basic INNER JOIN
SELECT 
    trips.id AS trip_id,
    trips.date,
    trips.cost,
    cars.id AS car_id,
    cars.model,
    cars.color,
    cars.status
FROM trips
INNER JOIN cars ON trips.car_id = cars.id;

-- INNER JOIN with additional info
SELECT 
    trips.id AS trip_id,
    riders.first_name AS rider_name,
    cars.model AS car_model,
    trips.cost,
    trips.date
FROM trips
INNER JOIN riders ON trips.rider_id = riders.id
INNER JOIN cars ON trips.car_id = cars.id
ORDER BY trips.date DESC;

-- ============================================
-- TASK 6: UNION (riders and riders2)
-- ============================================

-- Stack tables
SELECT * FROM riders
UNION
SELECT * FROM riders2;

-- Count total riders after union
SELECT COUNT(*) AS total_riders
FROM (
    SELECT * FROM riders
    UNION
    SELECT * FROM riders2
);

-- UNION ALL (includes duplicates if any)
SELECT * FROM riders
UNION ALL
SELECT * FROM riders2;

-- ============================================
-- TASK 7: AVERAGE COST
-- ============================================

-- Simple average
SELECT ROUND(AVG(cost), 2) AS average_trip_cost
FROM trips;

-- More detailed cost analysis
SELECT 
    ROUND(AVG(cost), 2) AS avg_cost,
    MIN(cost) AS min_cost,
    MAX(cost) AS max_cost,
    ROUND(AVG(cost) - MIN(cost), 2) AS range_span,
    COUNT(*) AS total_trips
FROM trips;

-- Average cost by month
SELECT 
    strftime('%Y-%m', date) AS month,
    ROUND(AVG(cost), 2) AS avg_cost,
    COUNT(*) AS trips_count
FROM trips
GROUP BY month
ORDER BY month DESC;

-- ============================================
-- TASK 8: RIDERS WITH < 500 TRIPS
-- ============================================

-- Basic query
SELECT *
FROM riders
WHERE total_trips < 500;

-- With ordering
SELECT 
    id,
    first_name,
    last_name,
    total_trips
FROM riders
WHERE total_trips < 500
ORDER BY total_trips ASC;

-- Count of irregular users
SELECT COUNT(*) AS irregular_users
FROM riders
WHERE total_trips < 500;

-- Percentage of irregular users
SELECT 
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM riders), 2) AS percentage_irregular
FROM riders
WHERE total_trips < 500;

-- ============================================
-- TASK 9: ACTIVE CARS COUNT
-- ============================================

-- Count active cars
SELECT COUNT(*) AS active_cars
FROM cars
WHERE status = 'active';

-- Breakdown by status
SELECT 
    status,
    COUNT(*) AS car_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM cars), 2) AS percentage
FROM cars
GROUP BY status;

-- Active cars with details
SELECT 
    id,
    model,
    color,
    year,
    trips_completed
FROM cars
WHERE status = 'active'
ORDER BY trips_completed DESC;

-- ============================================
-- TASK 10: TOP 2 CARS BY TRIPS COMPLETED
-- ============================================

-- Top 2 cars
SELECT *
FROM cars
ORDER BY trips_completed DESC
LIMIT 2;

-- Top 2 active cars only
SELECT *
FROM cars
WHERE status = 'active'
ORDER BY trips_completed DESC
LIMIT 2;

-- With rank (in case of ties)
SELECT 
    id,
    model,
    color,
    trips_completed,
    RANK() OVER (ORDER BY trips_completed DESC) AS rank
FROM cars
WHERE trips_completed IS NOT NULL
ORDER BY trips_completed DESC
LIMIT 2;

-- ============================================
-- BONUS QUERIES
-- ============================================

-- Revenue analysis
SELECT 
    ROUND(SUM(cost), 2) AS total_revenue,
    ROUND(AVG(cost), 2) AS avg_trip_value,
    COUNT(*) AS total_trips,
    ROUND(AVG(cost) * COUNT(*), 2) AS projected_monthly
FROM trips;

-- Most frequent riders
SELECT 
    riders.id,
    riders.first_name,
    riders.last_name,
    riders.total_trips,
    COUNT(trips.id) AS actual_trips
FROM riders
LEFT JOIN trips ON riders.id = trips.rider_id
GROUP BY riders.id
ORDER BY riders.total_trips DESC
LIMIT 10;

-- Car usage efficiency
SELECT 
    cars.id,
    cars.model,
    cars.trips_completed,
    COUNT(trips.id) AS trips_in_table,
    ROUND(COUNT(trips.id) * 100.0 / cars.trips_completed, 2) AS trip_coverage
FROM cars
LEFT JOIN trips ON cars.id = trips.car_id
GROUP BY cars.id
ORDER BY cars.trips_completed DESC;

-- Monthly trends
SELECT 
    strftime('%Y-%m', date) AS month,
    COUNT(*) AS trip_count,
    ROUND(AVG(cost), 2) AS avg_cost,
    ROUND(SUM(cost), 2) AS total_revenue
FROM trips
GROUP BY month
ORDER BY month DESC;

-- Rider segmentation
SELECT 
    CASE
        WHEN total_trips = 0 THEN 'Never Used'
        WHEN total_trips < 10 THEN 'New'
        WHEN total_trips < 50 THEN 'Occasional'
        WHEN total_trips < 200 THEN 'Regular'
        ELSE 'Power User'
    END AS rider_type,
    COUNT(*) AS user_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM riders), 2) AS percentage
FROM riders
GROUP BY rider_type
ORDER BY MIN(total_trips);