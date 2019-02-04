/* How many campaigns does CoolTShirts use? */

SELECT COUNT(DISTINCT utm_campaign)
FROM page_visits;



/* How many sources does CoolTShirts use? */

SELECT COUNT(DISTINCT utm_source)
FROM page_visits;



/* Which source is used for each campaign? */

SELECT DISTINCT utm_source, 
	        utm_campaign
FROM page_visits;



/* What pages are on the CoolTShirts website? */

SELECT DISTINCT page_name
FROM page_visits;



/* How many first touches is each campaign responsible for? */
WITH first_touch AS (
    SELECT user_id,
        MIN(timestamp) as first_touch_at
    FROM page_visits
    GROUP BY user_id),
ft_attr AS (
SELECT ft.user_id,
       ft.first_touch_at,
       pv.utm_source,
       pv.utm_campaign
FROM first_touch ft
  JOIN page_visits pv
    ON ft.user_id = pv.user_id
    AND ft.first_touch_at = pv.timestamp
)
SELECT ft_attr.utm_source AS 'First_Source',
       ft_attr.utm_campaign AS 'First_Campaign',
       COUNT(*) AS 'First_Touches'
FROM ft_attr
GROUP BY 1,2
ORDER BY 3 DESC;



/* How many last touches is each campaign responsible for? */

WITH last_touch AS (
    SELECT user_id,
           MAX(timestamp) as last_touch_at
    FROM page_visits
    GROUP BY user_id),
lt_attr AS (
SELECT lt.user_id,
       lt.last_touch_at,
       pv.utm_source,
       pv.utm_campaign
FROM last_touch lt
  JOIN page_visits pv
    ON lt.user_id = pv.user_id
    AND lt.last_touch_at = pv.timestamp
)
SELECT lt_attr.utm_source AS 'Last_Source',	    
       lt_attr.utm_campaign AS 'Last_Campaign',
       COUNT(*) AS 'Last_Touches'
FROM lt_attr
GROUP BY 1,2
ORDER BY 3 DESC;



/* How many visitors make a purchase? */

SELECT page_name AS 'CTS page', 
       COUNT(DISTINCT user_id) AS 'Unique User Hits'
FROM page_visits
GROUP BY page_name;



/* How many last touches on the purchase page is each campaign responsible for? */
WITH last_touch AS (
  SELECT user_id,
         MAX(timestamp) AS last_touch_at
  FROM page_visits
  WHERE page_name = '4 - purchase'
  GROUP BY user_id),
lt_attr AS (
SELECT lt.user_id,
       lt.last_touch_at,
       pv.utm_source,
       pv.utm_campaign
FROM last_touch lt
  JOIN page_visits pv
    ON lt.user_id = pv.user_id
    AND lt.last_touch_at = pv.timestamp
)
SELECT lt_attr.utm_source AS 'Last_Source',
       lt_attr.utm_campaign AS 'Last_Campaign',
       COUNT(*) AS 'Last_Touches'
FROM lt_attr
GROUP BY 1,2
ORDER BY 3 DESC;



/* Custom query to find relationship between first- and last- touchpoints */

WITH first_UTM_campaign AS
(
WITH first_touch AS (
     SELECT user_id,
            MIN(timestamp) as first_touch_at
     FROM page_visits
     GROUP BY user_id)
SELECT ft.user_id,
       ft.first_touch_at,
       pv.utm_source,
       pv.utm_campaign
FROM first_touch ft
  JOIN page_visits pv
    ON ft.user_id = pv.user_id
    AND ft.first_touch_at = pv.timestamp),
last_UTM_campaign AS
(
  WITH last_touch AS (
    SELECT user_id,
           MAX(timestamp) as last_touch_at
    FROM page_visits
    WHERE page_name = '4 - purchase'
    GROUP BY user_id)
SELECT lt.user_id,
       lt.last_touch_at,
       pv2.utm_source,
       pv2.utm_campaign
FROM last_touch lt
  JOIN page_visits pv2
    ON lt.user_id = pv2.user_id
    AND lt.last_touch_at = pv2.timestamp)
SELECT lc.user_id AS User,
       fc.utm_source AS First_Source,
       fc.utm_campaign AS First_Campaign,
       fc.first_touch_at AS First_Touch_At,
       lc.utm_source AS Last_Source,
       lc.utm_campaign AS Last_Campaign,
       lc.last_touch_at AS Last_Touch_At,
       CASE WHEN fc.utm_campaign = lc.utm_campaign
            THEN 'Single_Campaign'
            ELSE 'Multiple_Campaign'
            END AS Journey_Type
FROM last_UTM_campaign lc
	JOIN first_UTM_campaign fc
  	ON lc.user_id = fc.user_id
;
