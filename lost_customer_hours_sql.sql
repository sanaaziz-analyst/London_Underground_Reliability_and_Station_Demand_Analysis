create database london;
use london;
CREATE TABLE clean_lost_customer_hours (
    financial_year VARCHAR(10),
    period INT,
    lost_customer_hours INT
);
select*from clean_lost_customer_hours
#Total lost customer hours per year
SELECT financial_year,
       SUM(lost_customer_hours) AS total_lch
FROM clean_lost_customer_hours
GROUP BY financial_year
ORDER BY financial_year;

#Year-over-Year change (YoY)
WITH yearly AS (
    SELECT financial_year,
           SUM(lost_customer_hours) AS total_lch
    FROM clean_lost_customer_hours
    GROUP BY financial_year
)
SELECT financial_year,
       total_lch,
       LAG(total_lch) OVER (ORDER BY financial_year) AS prev_year,
       ROUND(
           (total_lch - LAG(total_lch) OVER (ORDER BY financial_year)) 
           / LAG(total_lch) OVER (ORDER BY financial_year) * 100, 2
       ) AS yoy_change
FROM yearly;

#Worst periods
SELECT period,
       SUM(lost_customer_hours) AS total_lch
FROM clean_lost_customer_hours
GROUP BY period
ORDER BY total_lch DESC;

#Trend across periods for each year
SELECT financial_year, period, lost_customer_hours
FROM clean_lost_customer_hours
ORDER BY financial_year, period;

#Best year vs worst year
SELECT financial_year, SUM(lost_customer_hours) AS total_lch
FROM clean_lost_customer_hours
GROUP BY financial_year
ORDER BY total_lch ASC;   -- lowest first

