USE saas_funnel;

-- ================================================
-- FUNNEL AGGREGATION ANALYSIS
-- Business Question: Where are users dropping off?
-- ================================================

SELECT * FROM saas_funnel_cleaned;

SELECT
    COUNT(*) as visited_site,
    SUM(CASE WHEN signed_up = 'Yes' THEN 1 ELSE 0 END) as signed_up,
    SUM(CASE WHEN completed_onboarding = 'Yes' THEN 1 ELSE 0 END) as completed_onboarding,
    SUM(CASE WHEN activated_core_feature = 'Yes' THEN 1 ELSE 0 END) as activated_core_feature,
    SUM(CASE WHEN started_trial = 'Yes' THEN 1 ELSE 0 END) as started_trial,
    SUM(CASE WHEN converted_to_paid = 'Yes' THEN 1 ELSE 0 END) as converted_to_paid,
    SUM(CASE WHEN active_after_30_days = 'Yes' THEN 1 ELSE 0 END) as active_after_30_days
FROM saas_funnel_cleaned;

-- RESULTS:
-- Visited Site:            7,200  (100%)
-- Signed Up:               6,149  (85.4%)
-- Completed Onboarding:    4,358  (60.5%)
-- Activated Core Feature:  2,859  (39.7%)
-- Started Trial:           1,586  (22.0%)
-- Converted to Paid:         628  (8.7%)
-- Active After 30 Days:      495  (6.9%)

-- Biggest drop-off is between 
-- Signed Up and Completed Onboarding
-- 1,791 users lost at this stage

-- Conversion rates between each stages

SELECT
    COUNT(*) as visited_site,
    SUM(CASE WHEN signed_up = 'Yes' THEN 1 ELSE 0 END) as signed_up,
    ROUND(SUM(CASE WHEN signed_up = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) as signup_rate,
    
    SUM(CASE WHEN completed_onboarding = 'Yes' THEN 1 ELSE 0 END) as completed_onboarding,
    ROUND(SUM(CASE WHEN completed_onboarding = 'Yes' THEN 1 ELSE 0 END) / 
          SUM(CASE WHEN signed_up = 'Yes' THEN 1 ELSE 0 END) * 100, 1) as onboarding_rate,
    
    SUM(CASE WHEN activated_core_feature = 'Yes' THEN 1 ELSE 0 END) as activated,
    ROUND(SUM(CASE WHEN activated_core_feature = 'Yes' THEN 1 ELSE 0 END) / 
          SUM(CASE WHEN completed_onboarding = 'Yes' THEN 1 ELSE 0 END) * 100, 1) as activation_rate,
    
    SUM(CASE WHEN started_trial = 'Yes' THEN 1 ELSE 0 END) as started_trial,
    ROUND(SUM(CASE WHEN started_trial = 'Yes' THEN 1 ELSE 0 END) / 
          SUM(CASE WHEN activated_core_feature = 'Yes' THEN 1 ELSE 0 END) * 100, 1) as trial_rate,
    
    SUM(CASE WHEN converted_to_paid = 'Yes' THEN 1 ELSE 0 END) as converted,
    ROUND(SUM(CASE WHEN converted_to_paid = 'Yes' THEN 1 ELSE 0 END) / 
          SUM(CASE WHEN started_trial = 'Yes' THEN 1 ELSE 0 END) * 100, 1) as conversion_rate,
    
    SUM(CASE WHEN active_after_30_days = 'Yes' THEN 1 ELSE 0 END) as retained,
    ROUND(SUM(CASE WHEN active_after_30_days = 'Yes' THEN 1 ELSE 0 END) / 
          SUM(CASE WHEN converted_to_paid = 'Yes' THEN 1 ELSE 0 END) * 100, 1) as retention_rate

FROM saas_funnel_cleaned;

-- So we are losing almost 1 in 3 users at onboarding
-- that's the biggest problem we found
-- users sign up but never finish setup

-- trial to paid is also weak at 39.6%
-- only 4 out of 10 trial users actually pay
-- but once they pay, 79% stick around which is good

-- main recommendation: fix onboarding first