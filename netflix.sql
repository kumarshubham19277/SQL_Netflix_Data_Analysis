create table if not exists netflix
(
	show_id varchar(10),
	type varchar(15),
	title varchar(300),
	director varchar(600),
	casts varchar(1100),
	country varchar(600),
	date_added varchar(75),
	release_year int,
	rating varchar(25),
	duration varchar(25),
	listed_in varchar(300),
	description varchar(600)
);

-- Data Exploration
select * from netflix;

SELECT count(*) as total
FROM netflix;

SELECT DISTINCT(type) FROM netflix; 

-- Business Problems

-- 1. Count the number of the Movies vs TV Shows
SELECT
	type,
	count(*) as total_content
FROM netflix
GROUP BY 1;

-- 2. Find the most common rating for movies and TV shows
SELECT
	type,
	rating
FROM
(
SELECT
	type,
	rating,
	count(*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
FROM netflix
GROUP BY 1, 2
) as t1
WHERE
	ranking = 1;

-- 3. List all movies released in a specific year (e.g., 2020)
SELECT * 
FROM netflix
WHERE release_year = '2020' AND type = 'Movie';

-- 4. Find the top 5 countries with the most content on netflix
SELECT
	UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
	COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 5. Identify the longest movie
SELECT * 
FROM netflix
WHERE
	type = 'Movie'
	AND
	duration = (SELECT MAX(duration) FROM netflix);

-- 6. Find content added in the last 5 years.
SELECT * FROM netflix
WHERE
	TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 YEAR';

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'
SELECT
	*
FROM netflix
WHERE
	director ILIKE '%Rajiv Chilaka%';

-- 8. List all TV Shows with more than 5 Seasons
SELECT
	*
FROM netflix
WHERE
	type = 'TV Show'
	AND
	duration > '5 Seasons';

-- 9. Count the number of content items in each genre.
SELECT
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
	COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC;

-- 10. Find each year and the average number of content release by India on netflix, return top 5 years with highest avg content release.
SELECT
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year,
	COUNT (*) as yearly_content,
	ROUND(
	COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100, 2) AS avg_content_per_year
	FROM netflix
	WHERE country = 'India'
	GROUP BY 1;

-- 11. List all movies that are documentries
SELECT *
FROM netflix
WHERE
	type ILIKE '%movie%'
	AND
	listed_in ILIKE '%documentaries%';

-- 12. Find all content without a director
SELECT *
FROM netflix
WHERE
	director IS NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years
SELECT *
FROM netflix
WHERE
	casts ILIKE '%salman khan%'
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India
SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

/*
15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
	the description field. Label content containing these keywords as 'Bad' and all other 
	content as 'Good'. Count how many items fall into each category.
*/
SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2