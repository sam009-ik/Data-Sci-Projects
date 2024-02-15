CREATE TABLE IF NOT EXISTS films (
	film_name TEXT,
	release_year INT
);
INSERT INTO 
	films (film_name, release_year)
VALUES
	('Date Movie',2006),
	('Saltburn', 2023),
	('Fight Club', 1999);
	
SELECT 
	* 
FROM 
	films
WHERE release_year = 1999;

ALTER TABLE
	films
ADD COLUMN runtime_min INT,
ADD COLUMN category VARCHAR (100),
ADD COLUMN rating REAL,
ADD COLUMN director TEXT;

UPDATE films
SET runtime_min = 139,
	category = 'Drama',
 	rating = 8.8,
 	director = 'David Fincher'
WHERE film_name = 'Fight Club'
RETURNING *;

UPDATE films
SET runtime_min = 136,
	category = 'Sci-fy Action',
	rating = 8.7,
	director = 'Lana Wachowski, Lilly Wachowski'
WHERE film_name = 'The Matrix'
RETURNING *;

UPDATE films
SET runtime_min = 131,
	category = 'Comedy',
 	rating = 7.2,
 	director = 'Emerald Fennel'
WHERE film_name = 'Saltburn'
RETURNING *;

UPDATE films
SET runtime_min = 83,
	category = 'Romance, Comedy',
 	rating = 2.8,
 	director = 'Aaron Seltzer, Jason Friedberg'
WHERE film_name LIKE '%Movie'
RETURNING *;

UPDATE films
SET runtime_min = 132,
	category = 'Drama, Romance',
 	rating = 7.8,
 	director = 'Luca Guadagnino'
WHERE film_name = 'Call Me By Your Name'
RETURNING *;

UPDATE films
SET runtime_min = 92,
	category = 'Animation, Comedy',
 	rating = 8.1,
 	director = 'Pete Docter, David Silverman, Lee Unkrich'
WHERE film_name LIKE 'Monster%'
RETURNING *;

ALTER TABLE IF EXISTS films
ADD CONSTRAINT unique_film_name UNIQUE (film_name); 

--If I try to add a movie name which already exists --
INSERT INTO films (film_name)
VALUES ('The Matrix');
--Gives me a unique constraint--

SELECT * FROM films;	