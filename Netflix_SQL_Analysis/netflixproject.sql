--Netflix Project

CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

select * from netflix;

select count(*) as total_content from netflix;

select distinct(type), count(*) from netflix
group by type;

---------------15 Bussiness Problems
--1. Count  the number of Movies vs TV Shows

select distinct(type), count(*) from netflix
group by type;

select type, count(*) as total_content
from netflix
group by 1;          --here group by 1 means it will select the 1st value from select statement 

--2. Find the most common rating for movies and Tv shows

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;

--3. List all movies released in a specific year (e.g., 2020)

select * from netflix
where release_year = 2020;

--4. Find the Top 5 Countries with the Most Content on Netflix

select 
	unnest(string_to_array(country, ',')) as new_country, 
	count(show_id) as total_content 
	from netflix
group by 1 
order by 2 desc
limit 5;
                       --or--
SELECT * 
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;

--5. Identify the longest movie?

select * from netflix;

SELECT *FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;

--6. Find content added in the last 5 years

SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'

select * from netflix
where director like '%Rajiv Chilaka%'


SELECT *FROM (
    SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
) 
WHERE director_name = 'Rajiv Chilaka';

select * from netflix                      --- valid if name is not with someone else with comman .
where director ilike '%Rajiv Chilaka'

--8. List All TV Shows with More Than 5 Seasons

select *
from netflix
where 
	type= 'TV Show'
	and 
	split_part(duration, ' ', 1)::int >5;

--split part eg            and :: is used to convert string to numeric/int
select 
	split_part('apple bannana cherry', ' ', 2);

--9.  Count the Number of Content Items in Each Genre

select 
	unnest(string_to_array(listed_in, ',')) as genre,
	count(show_id) as total_content
	from netflix
	group by 1;

--10. Find each year and the average numbers of content release in India on netflix.

SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

--11. List All Movies that are Documentaries

select * from netflix
where listed_in like '%Documentaries%'

--12. Find All Content Without a Director

select * from netflix
where director is null;

--13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

--14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

select 
	unnest(string_to_array(casts,',')) as actor,
	count(show_id)
from netflix
group by 1
order by 2 desc
limit 10;

--15.Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
--using cet 
with new_table as 
(select *,
	case when 
			description ilike '%kill%' or
			description ilike '%violence%'
	then 'Bad_Content'
	else 'Good_Content'
	end as category
from netflix
)
SELECT 
    category,
    COUNT(*) AS content_count
	from new_table
	group by category;

--or 

SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;