-- 1. View entire table
SELECT * FROM nomnom;

-- 2. Distinct neighborhoods
SELECT DISTINCT neighborhood FROM nomnom;

-- 3. Distinct cuisine types
SELECT DISTINCT cuisine FROM nomnom;

-- 4. Chinese takeout options
SELECT * FROM nomnom WHERE cuisine = 'Chinese';

-- 5. Restaurants with reviews 4+
SELECT * FROM nomnom WHERE review >= 4;

-- 6. Italian and $$$ restaurants
SELECT * FROM nomnom WHERE cuisine = 'Italian' AND price = '$$$';

-- 7. Restaurant with 'meatball' in name
SELECT * FROM nomnom WHERE name LIKE '%meatball%';

-- 8. Spots in Midtown, Downtown, or Chinatown
SELECT * FROM nomnom WHERE neighborhood IN ('Midtown', 'Downtown', 'Chinatown');

-- 9. Health grade pending (NULL values)
SELECT * FROM nomnom WHERE health IS NULL;

-- 10. Top 10 restaurants by review
SELECT * FROM nomnom ORDER BY review DESC LIMIT 10;

-- 11. Rating categories with CASE statement
SELECT 
    name,
    neighborhood,
    cuisine,
    review,
    price,
    health,
    CASE
        WHEN review > 4.5 THEN 'Extraordinary'
        WHEN review > 4 THEN 'Excellent'
        WHEN review > 3 THEN 'Good'
        WHEN review > 2 THEN 'Fair'
        ELSE 'Poor'
    END AS rating_category
FROM nomnom
ORDER BY review DESC;