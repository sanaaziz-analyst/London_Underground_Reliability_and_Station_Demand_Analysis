create database london;
use london;
CREATE TABLE clean_station_footfall (
    nlc INT,
    station VARCHAR(100),
    note VARCHAR(50),
    entry_weekday INT,
    entry_saturday INT,
    entry_sunday INT,
    exit_weekday INT,
    exit_saturday INT,
    exit_sunday INT,
    annual_entry_exit_million FLOAT,
    borough VARCHAR(50),
    year INT,
    total_weekday INT,
    total_weekend INT
);

#Top 10 stations by total footfall (across all years)
SELECT station,
       SUM(annual_entry_exit_million) AS total_footfall_million
FROM clean_station_footfall
GROUP BY station
ORDER BY total_footfall_million DESC
LIMIT 10;

#Which stations grew the fastest, 2011 → 2017?  # A = old value (2011) ,B = new value (2017) "percent growth"/percentage change formula:  ((B - A) / A) × 100, ASC for declining and DESC for growth
SELECT f2011.station,
       f2011.annual_entry_exit_million AS footfall_2011,
       f2017.annual_entry_exit_million AS footfall_2017,
       ROUND(
           (f2017.annual_entry_exit_million - f2011.annual_entry_exit_million)
           / f2011.annual_entry_exit_million * 100, 2
       ) AS pct_growth
FROM clean_station_footfall f2011
JOIN clean_station_footfall f2017
     ON TRIM(f2011.station) = TRIM(f2017.station)
WHERE f2011.year = 2011 AND f2017.year = 2017
AND f2011.annual_entry_exit_million > 0 #as blackfriars giving 0 value
ORDER BY pct_growth DESC
LIMIT 10;

#weekday vs weekend usage ratio
SELECT station,
       year,
       total_weekday,
       total_weekend,
       ROUND(total_weekday / total_weekend, 2) AS weekday_weekend_ratio
FROM clean_station_footfall
WHERE year = 2017
ORDER BY weekday_weekend_ratio DESC
LIMIT 10;

#borough-level footfall totals and growth 
SELECT borough,
       year,
       SUM(annual_entry_exit_million) AS total_footfall
FROM clean_station_footfall
WHERE borough IS NOT NULL AND borough != ''
GROUP BY borough, year
ORDER BY borough, year;


#which boroughs grew fastest?    #  instead of joining the raw table to itself directly, we first build two subqueries — one that calculates each 
#borough's total for 2014, one for 2017 — and then join those results together. We need this extra step because "borough total" itself requires a SUM()/GROUP BY 
#first (a borough has many stations), whereas station-level growth didn't need that pre-aggregation step
SELECT b2014.borough,
       b2014.total_footfall AS footfall_2014,
       b2017.total_footfall AS footfall_2017,
       ROUND(
           (b2017.total_footfall - b2014.total_footfall) / b2014.total_footfall * 100, 2
       ) AS pct_growth
FROM (
    SELECT borough, SUM(annual_entry_exit_million) AS total_footfall
    FROM clean_station_footfall
    WHERE year = 2014 AND borough IS NOT NULL AND borough != ''
    GROUP BY borough
) b2014
JOIN (
    SELECT borough, SUM(annual_entry_exit_million) AS total_footfall
    FROM clean_station_footfall
    WHERE year = 2017 AND borough IS NOT NULL AND borough != ''
    GROUP BY borough
) b2017
ON b2014.borough = b2017.borough
ORDER BY pct_growth DESC;


SELECT lch.financial_year,
       lch.total_lch,
       ff.total_footfall
FROM (
    SELECT financial_year, SUM(lost_customer_hours) AS total_lch
    FROM clean_lost_customer_hours
    GROUP BY financial_year
) lch
JOIN (
    SELECT year, SUM(annual_entry_exit_million) AS total_footfall
    FROM clean_station_footfall
    GROUP BY year
) ff
ON LEFT(lch.financial_year, 4) = ff.year # column like 2014/15 are chopped off as 2014 neccessary for validating query
ORDER BY lch.financial_year;