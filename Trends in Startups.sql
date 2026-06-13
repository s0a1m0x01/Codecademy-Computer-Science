-- 1. View all data
SELECT * FROM startups;

-- 2. Total companies
SELECT COUNT(*) AS total_companies FROM startups;

-- 3. Total valuation of all companies
SELECT SUM(valuation) AS total_valuation FROM startups;

-- 4. Highest amount raised
SELECT MAX(raised) AS highest_raised FROM startups;

-- 5. Highest amount raised in Seed stage
SELECT MAX(raised) AS highest_seed_raised 
FROM startups 
WHERE stage = 'Seed';

-- 6. Oldest company founding year
SELECT MIN(founded) AS oldest_founded FROM startups;

-- 7. Average valuation
SELECT AVG(valuation) AS avg_valuation FROM startups;

-- 8. Average valuation by category
SELECT category, AVG(valuation) AS avg_valuation
FROM startups
GROUP BY category;

-- 9. Average valuation by category (rounded)
SELECT category, ROUND(AVG(valuation), 2) AS avg_valuation
FROM startups
GROUP BY category;

-- 10. Average valuation by category, rounded, highest first
SELECT category, ROUND(AVG(valuation), 2) AS avg_valuation
FROM startups
GROUP BY category
ORDER BY avg_valuation DESC;

-- 11. Company count by category
SELECT category, COUNT(*) AS company_count
FROM startups
GROUP BY category;

-- 12. Categories with more than 3 companies
SELECT category, COUNT(*) AS company_count
FROM startups
GROUP BY category
HAVING company_count > 3;

-- 13. Average company size by location
SELECT location, AVG(employees) AS avg_employees
FROM startups
GROUP BY location;

-- 14. Average company size by location (avg > 500)
SELECT location, AVG(employees) AS avg_employees
FROM startups
GROUP BY location
HAVING avg_employees > 500;