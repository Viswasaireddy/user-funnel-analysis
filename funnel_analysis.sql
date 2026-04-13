
-- 1. PREVIEW DATA

SELECT TOP 10 *
FROM dbo.ecommerce_behavior_data;



-- 2. FUNNEL COUNT
SELECT event_type, COUNT(DISTINCT user_id) AS users
FROM dbo.ecommerce_behavior_data
GROUP BY event_type
ORDER BY users DESC;


-- 3. FULL FUNNEL
SELECT 
COUNT(DISTINCT CASE WHEN event_type = 'view' THEN user_id END) AS views,
COUNT(DISTINCT CASE WHEN event_type = 'cart' THEN user_id END) AS carts,
COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS purchases
FROM dbo.ecommerce_behavior_data;


-- 4. CONVERSION RATE
SELECT 
CAST(
COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) * 100.0 /
COUNT(DISTINCT CASE WHEN event_type = 'view' THEN user_id END)
AS DECIMAL(5,2)
) AS conversion_rate_percentage
FROM dbo.ecommerce_behavior_data;


-- 5. DROP-OFF ANALYSIS
SELECT 
COUNT(DISTINCT CASE WHEN event_type = 'view' THEN user_id END) -
COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS drop_off_users
FROM dbo.ecommerce_behavior_data;


-- 6. DAILY ACTIVE USERS (DAU)
SELECT 
CAST(event_time AS DATE) AS event_date,
COUNT(DISTINCT user_id) AS daily_active_users
FROM dbo.ecommerce_behavior_data
GROUP BY CAST(event_time AS DATE)
ORDER BY event_date;


-- 7. RETENTION (DAY 1 vs DAY 2)
WITH day1 AS (
    SELECT DISTINCT user_id
    FROM dbo.ecommerce_behavior_data
    WHERE CAST(event_time AS DATE) = (
        SELECT MIN(CAST(event_time AS DATE)) FROM dbo.ecommerce_behavior_data
    )
),
day2 AS (
    SELECT DISTINCT user_id
    FROM dbo.ecommerce_behavior_data
    WHERE CAST(event_time AS DATE) = (
        SELECT DATEADD(DAY, 1, MIN(CAST(event_time AS DATE))) FROM dbo.ecommerce_behavior_data
    )
)
SELECT 
COUNT(*) * 100.0 / (SELECT COUNT(*) FROM day1) AS retention_rate_percentage
FROM day1
WHERE user_id IN (SELECT user_id FROM day2);