USE saas_funnel;

-- ================================================
-- SEGMENT ANALYSIS
-- Business Question: Which segments convert best?
-- ================================================

SELECT * FROM saas_funnel_cleaned;

-- acquisition analysis

SELECT 
    acquisition_channel,
    COUNT(*) as total_users,
    SUM(CASE WHEN converted_to_paid = 'Yes' THEN 1 ELSE 0 END) as converted_users,
    ROUND(SUM(CASE WHEN converted_to_paid = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) as conversion_rate
FROM saas_funnel_cleaned
GROUP BY acquisition_channel
ORDER BY conversion_rate DESC;


-- organic search is free and converts the best at 9.4%
-- paid ads costs money but converts almost the same -- worth reviewing ROI
-- email campaign is cheaper than paid ads -- good alternative to invest in
-- direct is weakest at 6.5% -- users know us but still dont convert -- landing page problem?


-- device analysis

SELECT 
    device,
    COUNT(*) as total_users,
    SUM(CASE WHEN converted_to_paid = 'Yes' THEN 1 ELSE 0 END) as converted,
    ROUND(SUM(CASE WHEN converted_to_paid = 'Yes' THEN 1 ELSE 0 END) 
          / COUNT(*) * 100, 1) as conversion_rate
FROM saas_funnel_cleaned
GROUP BY device
ORDER BY conversion_rate DESC;

-- mobile has the most users but lowest conversion at 7.8% -- UX problem
-- desktop converts better at 9.0% despite similar user count
-- tablet converts best at 9.7% -- small but high quality segment
-- unknown device at 12.7% -- device not recorded, possibly laptop users


-- country analysis
SELECT country,
SUM(CASE WHEN converted_to_paid = "Yes" then 1 else 0 end) AS converted_users,
    ROUND(SUM(CASE WHEN converted_to_paid = 'Yes' THEN 1 ELSE 0 END) 
          / COUNT(*) * 100, 1) as conversion_rate
FROM saas_funnel_cleaned
group by country
order by conversion_rate desc;

-- Canada converts best at 11.5%
-- strong conversion efficiency despite smaller user base

-- United States generates most paid users (202)
-- largest opportunity for conversion improvement

-- United Kingdom and Australia show stable performance
-- conversion rates remain close to overall average

-- India has the lowest conversion rate (8.1%)
-- further analysis needed to identify bottlenecks

-- Conversion rates range from 8.1% to 11.5%
-- no major underperforming country segment detected
