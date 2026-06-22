USE saas_funnel;

-- ================================================
-- COHORT ANALYSIS
-- Business Question: How does user retention vary
-- across different signup cohorts over time?
-- ================================================

SELECT * FROM saas_funnel_cleaned;

SELECT date_format(signup_date,"%Y-%m") AS signup_month,
COUNT(*) AS Total_Users
FROM saas_funnel_cleaned
group by signup_month
order by signup_month;

SELECT date_format(signup_date,"%Y-%m") AS signup_month,
 COUNT(*) Total_Users,
 SUM(CASE WHEN active_after_30_days = "Yes" then 1 else 0 end) AS retained_users,
 ROUND((SUM(CASE WHEN active_after_30_days = "Yes" then 1 else 0 end)/count(*))*100,2) AS retention_rate
FROM saas_funnel_cleaned
WHERE signup_date IS NOT NULL
group by signup_month
order by signup_month;

-- Retention rates range from 5.3% to 12.4% across cohorts

-- June 2024 achieved the highest retention rate (12.43%)
-- indicating stronger long-term engagement

-- January 2025 also performed well with 11.65% retention

-- March 2025 recorded the lowest retention rate (5.31%)
-- suggesting weaker post-conversion engagement

-- Cohort retention remains relatively stable
-- with most cohorts falling between 6% and 9%

-- User acquisition increased over time
-- but larger cohorts did not necessarily achieve higher retention

-- Business Recommendation:
-- Investigate onboarding and engagement strategies
-- used in high-retention cohorts (Jun 2024, Jan 2025)
-- and apply those learnings to lower-performing cohorts
