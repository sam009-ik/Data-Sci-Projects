-- Homework 3
Use mit;
SELECT * FROM zipcodes LIMIT 10;
SELECT * FROM census_income_by_zipcodes;

-- Create a function to calculate the Euclidean Distance between two sets of coordinates
DROP FUNCTION IF EXISTS distBwPoints;
DELIMITER //
CREATE FUNCTION distBwPoints(x1 DOUBLE, y1 DOUBLE, x2 DOUBLE, y2 DOUBLE)
RETURNS DOUBLE
deterministic
BEGIN
    RETURN ROUND(SQRT(POWER((x1 - x2), 2) + POWER((y1 - y2), 2)), 2);
END //

DELIMITER ;
SELECT distBwPoints(40.745221, -73.978294, 42.362986, -71.103353);

-- Q2 Dataset Exploration
-- a
SELECT 
    ci.ZipcodesGeoid_PK_FK AS Zipcodes,
    AVG(CASE
        WHEN ci.GraduateOrProfessionalDegree < 5000 THEN 5000
        WHEN ci.GraduateOrProfessionalDegree > 20000 THEN 20000
        ELSE ci.GraduateOrProfessionalDegree
    END) AS AvgGraduateOrProfessionalDegree,
    AVG(CASE
        WHEN ci.BachelorsDegree < 5000 THEN 5000
        WHEN ci.BachelorsDegree > 20000 THEN 20000
        ELSE ci.BachelorsDegree
    END) AS AvgBachelorsDegree
FROM
    census_income_by_zipcodes ci
        JOIN
    zipcodes zp ON ci.ZipcodesGeoid_PK_FK = zp.GEOID_PK
GROUP BY 1;

-- b
SELECT GraduateOrProfessionalDegree FROM census_income_by_zipcodes WHERE GraduateOrProfessionalDegree IS NULL;
SELECT COUNT(GraduateOrProfessionalDegree) FROM census_income_by_zipcodes WHERE GraduateOrProfessionalDegree = 0; #10312 rows are zero
SELECT COUNT(*) FROM census_income_by_zipcodes WHERE GraduateOrProfessionalDegree > 0;
SELECT GraduateOrProfessionalDegree FROM census_income_by_zipcodes;
-- Zip code with max income    
SELECT 
	ci.ZipcodesGeoid_PK_FK AS Zipcode,
    ci.GraduateOrProfessionalDegree AS MaxIncome
FROM census_income_by_zipcodes ci
WHERE ci.GraduateOrProfessionalDegree = (
	SELECT MAX(GraduateOrProfessionalDegree)
    FROM census_income_by_zipcodes
    WHERE GraduateOrProfessionalDegree > 0
);
-- Zipcode with min income
SELECT 
	ci.ZipcodesGeoid_PK_FK AS Zipcode,
    ci.GraduateOrProfessionalDegree AS MinIncome
FROM census_income_by_zipcodes ci
WHERE ci.GraduateOrProfessionalDegree = (
	SELECT MIN(GraduateOrProfessionalDegree)
    FROM census_income_by_zipcodes
    WHERE GraduateOrProfessionalDegree > 0
);
/*Which two zip codes that start with “12” in the 2018_Gaz_zcta_national dataset, are
the closest to one other?*/
WITH 
zp AS (SELECT * FROM zipcodes WHERE GEOID_PK LIKE "12%") -- 525 zipcodes
SELECT zp1.GEOID_PK AS zipcode1,
zp2.GEOID_PK AS zipcode2,
distBwPoints(zp1.INTPTLAT, zp1.INTPTLONG, zp2.INTPTLAT, zp2.INTPTLONG) AS Distance
FROM zp zp1
CROSS JOIN zp zp2
WHERE zp1.GEOID_PK != zp2.GEOID_PK
ORDER BY Distance ASC LIMIT 1;

/*Question 3:
For the following latitudes and longitudes, find and report the nearest zip code:
a. 42.3597807, -71.0920143
b. 47.6205271, -122.349329
c. 40.7130125, -74.013133*/
-- Create a function that find nearest zip code
DELIMITER //
CREATE function nearest_zip(lat DECIMAL(9, 6), lon DECIMAL(9, 6))
RETURNS VARCHAR(45)
	DETERMINISTIC
BEGIN
	DECLARE zip_code VARCHAR(45);
		SET zip_code = (SELECT zp1.GEOID_PK FROM zipcodes zp1 ORDER BY distBwPoints(zp1.INTPTLAT, zp1.INTPTLONG, lat, lon) ASC LIMIT 1);
    RETURN zip_code;
END//
DELIMITER ;
SELECT nearest_zip(42.3597807, -71.0920143);
SELECT nearest_zip(47.6205271, -122.349329);
SELECT nearest_zip(40.7130125, -74.013133);

-- Question 4
ALTER TABLE census_income_by_zipcodes
CHANGE COLUMN census_income_zip census_zip_income DECIMAL(10, 0) NULL;
SELECT census_income_zip FROM census_income_by_zipcodes;

ALTER TABLE census_income_by_zipcodes
ADD COLUMN census_zip_income_zscore DOUBLE,
ADD COLUMN census_zip_income_category VARCHAR(30);

/*Calculate the z-score of each census income value and update the
“census_zip_income_zscore” field in each row.*/
UPDATE census_income_by_zipcodes czi
JOIN (
 SELECT AVG(census_zip_income) AvgIncome, STDDEV(census_zip_income) AS stddv
 FROM census_income_by_zipcodes
) AS stats
SET czi.census_zip_income_zscore = (czi.census_zip_income - stats.AvgIncome) / stats.stddv; 
SELECT census_zip_income_zscore FROM census_income_by_zipcodes;
-- z score preview
SELECT 
    czi.census_zip_income,
    (czi.census_zip_income - stats.avg_income) / stats.stddev_income AS z_score_preview
FROM
    census_income_by_zipcodes czi
        CROSS JOIN
    (SELECT 
        AVG(census_zip_income) AS avg_income,
            STDDEV(census_zip_income) AS stddev_income
    FROM
        census_income_by_zipcodes) AS stats;

UPDATE census_income_by_zipcodes czi 
SET 
    czi.census_zip_income_category = CASE
        WHEN czi.census_zip_income_zscore > 0.5 THEN 'High'
        WHEN czi.census_zip_income_zscore < -0.5 THEN 'Low'
        ELSE 'Medium'
    END;
SELECT * FROM census_income_by_zipcodes;

SELECT version();