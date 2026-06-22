USE saas_funnel;
SELECT * FROM saas_funnel_raw;

-- Finding duplicate user_id
SELECT user_id,COUNT(*) AS duplicate_count FROM saas_funnel_raw 
group by user_id having COUNT(*) > 1;

-- just checking the duplicate of an ID
SELECT * 
FROM saas_funnel_raw
WHERE user_id = '106001';

-- Issue 1 — removing exact duplicates and near duplicates

CREATE TABLE saas_funnel_cleaned AS 
WITH ranked_users AS(
	SELECT *,ROW_NUMBER() over(partition by user_id  order by session_count DESC) AS row_count
	FROM saas_funnel_raw
)
SELECT * FROM ranked_users where row_count = 1 ;

-- dropping row_count column from new table
ALTER TABLE saas_funnel_cleaned drop column row_count;
SELECT * FROM saas_funnel_cleaned limit 3;

-- Issue 2 : Fixing the country names

SELECT 
    country_raw,
    COUNT(*) as user_count
FROM saas_funnel_cleaned
GROUP BY country_raw
ORDER BY country_raw;

SELECT country_raw,CASE
WHEN LOWER(country_raw) IN ('america','u.s.a','usa','united states','us') 
    THEN 'United States'
WHEN LOWER(country_raw) IN ('ca','can.','canada') 
    THEN 'Canada'
WHEN LOWER(country_raw) IN ('de','deutschland','germany') 
    THEN 'Germany'
WHEN LOWER(country_raw) IN ('in','ind','india') 
    THEN 'India'
WHEN LOWER(country_raw) IN ('england','u.k.','uk','united kingdom') 
    THEN 'United Kingdom'
WHEN LOWER(country_raw) IN ('aus','au','australia') 
    THEN 'Australia' ELSE country_raw END country_clean
FROM saas_funnel_cleaned;

-- create a new country column 
ALTER TABLE saas_funnel_cleaned
ADD COLUMN country VARCHAR(50);

set sql_safe_updates = 0;
UPDATE saas_funnel_cleaned
SET country = CASE
    WHEN LOWER(country_raw) IN ('america','u.s.a','usa','united states','us') 
        THEN 'United States'
    WHEN LOWER(country_raw) IN ('ca','can.','canada') 
        THEN 'Canada'
    WHEN LOWER(country_raw) IN ('de','deutschland','germany') 
        THEN 'Germany'
    WHEN LOWER(country_raw) IN ('in','ind','india') 
        THEN 'India'
    WHEN LOWER(country_raw) IN ('england','u.k.','uk','united kingdom') 
        THEN 'United Kingdom'
    WHEN LOWER(country_raw) IN ('aus','au','australia') 
        THEN 'Australia'
    ELSE country_raw
END;


SELECT country, COUNT(*) 
FROM saas_funnel_cleaned
GROUP BY country
ORDER BY country;

UPDATE saas_funnel_cleaned SET country = "Unknown" where country is null; 


-- Issue 4 : device standardization
SELECT device_raw,COUNT(user_id) from saas_funnel_cleaned
group by device_raw
order by device_raw;

SELECT device_raw,CASE
WHEN lower(device_raw) in ('phone','mobile','mobile phone')  then "Mobile"
WHEN lower(device_raw) in ('tablet','ipad','tab')  then "Tablet"
WHEN lower(device_raw) in ('pc','desktop','desk top')  then "Desktop"
ELSE 'Unknown' END AS device FROM saas_funnel_cleaned;

ALTER TABLE saas_funnel_cleaned add column device varchar(50);

UPDATE saas_funnel_cleaned set device = CASE
WHEN lower(device_raw) in ('phone','mobile','mobile phone')  then "Mobile"
WHEN lower(device_raw) in ('tablet','ipad','tab')  then "Tablet"
WHEN lower(device_raw) in ('pc','desktop','desk top')  then "Desktop"
ELSE 'Unknown' END;

SELECT device,COUNT(user_id) from saas_funnel_cleaned
group by device
order by device;

-- Issue 05 Fixing Age 

-- Investigate
SELECT MIN(age) , MAX(age) from saas_funnel_cleaned;

SELECT age,COUNT(*) FROM saas_funnel_cleaned 
group by age;

-- creating new column for cleaned age
SET sql_safe_updates=0;
ALTER TABLE saas_funnel_cleaned add column age_clean INT;
UPDATE saas_funnel_cleaned set age_clean = 
CASE WHEN age between 13 and 90 then age else NULL end ;

-- test
SELECT age,age_clean FROM saas_funnel_cleaned where age_clean is null;
SELECT age_clean,COUNT(*) FROM saas_funnel_cleaned
group by age_clean;

DESCRIBE saas_funnel_cleaned;

ALTER TABLE saas_funnel_cleaned drop column row_count ;
ALTER TABLE saas_funnel_cleaned drop column country_raw;
ALTER TABLE saas_funnel_cleaned drop column device_raw;
ALTER TABLE saas_funnel_cleaned drop column age;

SELECT COUNT(*) 
FROM saas_funnel_cleaned
WHERE age_clean IS NULL;

-- Issue 6 : fixing marketing spend and session_count
ALTER TABLE saas_funnel_cleaned add column session_count_cleaned INT;
ALTER TABLE saas_funnel_cleaned add column marketing_spend_cleaned FLOAT;

UPDATE saas_funnel_cleaned set session_count_cleaned = 
CASE WHEN session_count >= 0 THEN session_count else NULL END ;

UPDATE saas_funnel_cleaned set marketing_spend_cleaned = 
CASE WHEN marketing_spend >= 0 THEN marketing_spend else NULL END ;

DESCRIBE saas_funnel_cleaned;

-- Issue 7 > Missing Values
UPDATE saas_funnel_cleaned set active_after_30_days = "Not Applicable"
WHERE converted_to_paid = "No";

SELECT active_after_30_days, COUNT(*) 
FROM saas_funnel_cleaned
GROUP BY active_after_30_days;

UPDATE saas_funnel_cleaned
SET plan_type = "Not Converted"
WHERE converted_to_paid = "No";

SELECT plan_type,COUNT(*) FROM  saas_funnel_cleaned
group by plan_type;

UPDATE saas_funnel_cleaned
SET marketing_spend_cleaned = marketing_spend;

UPDATE saas_funnel_cleaned
SET marketing_spend_cleaned = 0
WHERE acquisition_channel IN ('Organic Search', 'Referral');

UPDATE saas_funnel_cleaned
SET marketing_spend_cleaned = NULL
WHERE marketing_spend_cleaned < 0;

SELECT acquisition_channel,
       AVG(marketing_spend_cleaned) as avg_clean
FROM saas_funnel_cleaned
GROUP BY acquisition_channel;

-- Checking Funnel logic violation
SELECT COUNT(*) 
FROM saas_funnel_cleaned
WHERE signed_up = 'No' 
AND completed_onboarding = 'Yes';

SELECT COUNT(*) 
FROM saas_funnel_cleaned
WHERE converted_to_paid = 'No' 
AND plan_type NOT IN ('Not Converted');

-- Issue 08 Inconsistency in Dates

-- fixed using python
-- Mixed date formats fixed using pandas
-- Cleaned dates written back to MySQL

SELECT * FROM saas_funnel_cleaned;


-- Adding subsciption revenue
ALTER TABLE saas_funnel_cleaned
ADD COLUMN subscription_revenue INT;

UPDATE saas_funnel_cleaned
SET subscription_revenue =
CASE
    WHEN plan_type = 'Basic' THEN 29
    WHEN plan_type = 'Pro' THEN 79
    WHEN plan_type = 'Enterprise' THEN 199
    ELSE 0
END;

SELECT plan_type, subscription_revenue, COUNT(*) 
FROM saas_funnel_cleaned
GROUP BY plan_type, subscription_revenue;

SELECT * FROM saas_funnel_cleaned;

-- For tableau dashboard

CREATE TABLE saas_funnel_tableau AS
SELECT
    user_id,
    signup_date,
    onboarding_date,
    activation_date,
    trial_start_date,
    conversion_date,
    country,
    device,
    age_clean,
    acquisition_channel,
    signed_up,
    completed_onboarding,
    activated_core_feature,
    started_trial,
    converted_to_paid,
    active_after_30_days,
    plan_type,
    subscription_revenue,
    marketing_spend_cleaned
FROM saas_funnel_cleaned;

DESCRIBE saas_funnel_tableau;
