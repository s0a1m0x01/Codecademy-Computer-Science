-- ============================================
-- 1. UNDERSTANDING THE DATASET
-- ============================================

-- Top 5 highest scoring stories
SELECT title, score
FROM hacker_news
ORDER BY score DESC
LIMIT 5;

-- Basic statistics
SELECT 
    COUNT(*) AS total_stories,
    COUNT(DISTINCT user) AS unique_users,
    SUM(score) AS total_points,
    AVG(score) AS avg_score,
    MAX(score) AS highest_score
FROM hacker_news;

-- ============================================
-- 2. HACKER NEWS MODERATING (Power Users)
-- ============================================

-- Total score of all stories
SELECT SUM(score) AS total_score FROM hacker_news;

-- Users with combined scores > 200
SELECT user, SUM(score) AS total_score
FROM hacker_news
GROUP BY user
HAVING total_score > 200
ORDER BY total_score DESC;

-- Percentage from top users
SELECT 
    ROUND(SUM(CASE WHEN user IN (
        SELECT user FROM hacker_news 
        GROUP BY user 
        HAVING SUM(score) > 200
    ) THEN score ELSE 0 END) * 100.0 / SUM(score), 2) AS top_users_percentage,
    ROUND(SUM(CASE WHEN user NOT IN (
        SELECT user FROM hacker_news 
        GROUP BY user 
        HAVING SUM(score) > 200
    ) THEN score ELSE 0 END) * 100.0 / SUM(score), 2) AS other_users_percentage
FROM hacker_news;

-- ============================================
-- 3. RICKROLL OFFENDERS
-- ============================================

-- Count Rickroll posts by user
SELECT user, COUNT(*) AS rickroll_count
FROM hacker_news
WHERE url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'
GROUP BY user
ORDER BY rickroll_count DESC;

-- Total Rickroll posts
SELECT COUNT(*) AS total_rickrolls
FROM hacker_news
WHERE url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';

-- ============================================
-- 4. SOURCES THAT FEED HACKER NEWS
-- ============================================

-- Source categorization with more detail
SELECT 
    CASE
        WHEN url LIKE '%github.com%' THEN 'GitHub'
        WHEN url LIKE '%medium.com%' THEN 'Medium'
        WHEN url LIKE '%nytimes.com%' THEN 'New York Times'
        WHEN url LIKE '%youtube.com%' THEN 'YouTube'
        WHEN url LIKE '%twitter.com%' THEN 'Twitter'
        WHEN url LIKE '%stackoverflow.com%' THEN 'Stack Overflow'
        WHEN url LIKE '%arxiv.org%' THEN 'arXiv'
        WHEN url LIKE '%wikipedia.org%' THEN 'Wikipedia'
        ELSE 'Other'
    END AS source,
    COUNT(*) AS story_count,
    ROUND(AVG(score), 2) AS avg_score,
    SUM(score) AS total_points
FROM hacker_news
WHERE url IS NOT NULL
GROUP BY source
ORDER BY story_count DESC
LIMIT 10;

-- ============================================
-- 5. BEST TIME TO POST (Hour Analysis)
-- ============================================

-- Preview timestamps
SELECT timestamp FROM hacker_news LIMIT 10;

-- Test strftime function
SELECT 
    timestamp,
    strftime('%H', timestamp) AS hour,
    strftime('%Y-%m-%d', timestamp) AS date
FROM hacker_news
LIMIT 20;

-- Comprehensive hour analysis
SELECT 
    strftime('%H', timestamp) AS hour_of_day,
    ROUND(AVG(score), 2) AS avg_score,
    COUNT(*) AS number_of_posts,
    SUM(score) AS total_points,
    ROUND(SUM(score) * 100.0 / (SELECT SUM(score) FROM hacker_news), 2) AS percentage_of_total
FROM hacker_news
WHERE timestamp IS NOT NULL
GROUP BY hour_of_day
ORDER BY avg_score DESC;

-- Best hours for posting (high average score with enough data)
SELECT 
    strftime('%H', timestamp) AS hour_of_day,
    ROUND(AVG(score), 2) AS avg_score,
    COUNT(*) AS posts_count
FROM hacker_news
WHERE timestamp IS NOT NULL
GROUP BY hour_of_day
HAVING posts_count > 10  -- Only consider hours with sufficient data
ORDER BY avg_score DESC
LIMIT 5;

-- Hourly performance with time zone consideration
-- (Assuming UTC, convert to EST by subtracting 4 or 5 hours)
SELECT 
    CASE
        WHEN strftime('%H', timestamp) BETWEEN 0 AND 4 THEN 'Late Night (EST: Previous Day 8pm-12am)'
        WHEN strftime('%H', timestamp) BETWEEN 5 AND 8 THEN 'Early Morning (EST: 1am-4am)'
        WHEN strftime('%H', timestamp) BETWEEN 9 AND 12 THEN 'Morning (EST: 5am-8am)'
        WHEN strftime('%H', timestamp) BETWEEN 13 AND 16 THEN 'Afternoon (EST: 9am-12pm)'
        WHEN strftime('%H', timestamp) BETWEEN 17 AND 20 THEN 'Evening (EST: 1pm-4pm)'
        ELSE 'Night (EST: 5pm-8pm)'
    END AS est_time_block,
    ROUND(AVG(score), 2) AS avg_score,
    COUNT(*) AS posts_count
FROM hacker_news
WHERE timestamp IS NOT NULL
GROUP BY est_time_block
ORDER BY avg_score DESC;

-- ============================================
-- 6. ADDITIONAL INSIGHTS
-- ============================================

-- Most active users
SELECT user, COUNT(*) AS posts, SUM(score) AS total_points
FROM hacker_news
GROUP BY user
ORDER BY total_points DESC
LIMIT 10;

-- Score distribution by hour (box plot style)
SELECT 
    strftime('%H', timestamp) AS hour,
    MIN(score) AS min_score,
    MAX(score) AS max_score,
    ROUND(AVG(score), 2) AS avg_score,
    ROUND(AVG(score) - 2 * (AVG(score * score) - AVG(score) * AVG(score)), 2) AS approx_lower_bound
FROM hacker_news
WHERE timestamp IS NOT NULL
GROUP BY hour
ORDER BY hour;

-- Monthly trend analysis
SELECT 
    strftime('%Y-%m', timestamp) AS month,
    COUNT(*) AS posts_count,
    ROUND(AVG(score), 2) AS avg_score,
    SUM(score) AS total_points
FROM hacker_news
WHERE timestamp IS NOT NULL
GROUP BY month
ORDER BY month DESC
LIMIT 12;

-- Weekend vs Weekday analysis
SELECT 
    CASE 
        WHEN strftime('%w', timestamp) IN ('0', '6') THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    ROUND(AVG(score), 2) AS avg_score,
    COUNT(*) AS posts_count
FROM hacker_news
WHERE timestamp IS NOT NULL
GROUP BY day_type;