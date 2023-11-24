SELECT * FROM amitdb.movies;


-- (a)	Determine the total number of movies released each year and analyse the month-wise trend.

SELECT
    year,
    COUNT(*) AS total_movies
FROM
    amitdb.movies
GROUP BY
    year
ORDER BY
    year;
    
-- to analyze month wise trend 

SELECT
    SUBSTRING_INDEX(date_published, '-', -1) AS year,
    SUBSTRING_INDEX(SUBSTRING_INDEX(date_published, '-', 2), '-', -1) AS month,
    COUNT(*) AS total_movies
FROM
    amitdb.movies
WHERE
    date_published IS NOT NULL
GROUP BY
    SUBSTRING_INDEX(date_published, '-', -1), SUBSTRING_INDEX(SUBSTRING_INDEX(date_published, '-', 2), '-', -1)
ORDER BY
    year, month;

-- (b) Calculate the number of movies produced in the USA or India in the year 2019.
SELECT
    COUNT(*) AS total_movies
FROM
    amitdb.movies
WHERE
    (country = 'USA' OR country = 'India')
    AND year = 2019;

SELECT * FROM amitdb.genre;

-- (a)	Retrieve the unique list of genres present in the dataset.
SELECT DISTINCT genre
FROM amitdb.genre;

-- (b) Identify the genre with the highest number of movies produced overall.

SELECT
    genre,
    COUNT(movie_id) AS movie_count
FROM
    amitdb.genre
GROUP BY
    genre
ORDER BY
    movie_count DESC
LIMIT 1;

-- (c)	Determine the count of movies that belong to only one genre.

SELECT COUNT(*) AS single_genre_count
FROM (
    SELECT movie_id
    FROM amitdb.genre
    GROUP BY movie_id
    HAVING COUNT(DISTINCT genre) = 1
) AS single_genre_movies;

-- (d)	Calculate the average duration of movies in each genre.

SELECT
    genre,
    AVG(duration) AS average_duration
FROM
    amitdb.genre
JOIN amitdb.movies ON amitdb.genre.movie_id = amitdb.movies.id
GROUP BY
    genre;

-- (e)	Find the rank of the 'thriller' genre among all genres in terms of the number of movies produced.

SELECT
    genre,
    RANK() OVER (ORDER BY movie_count DESC) AS genre_rank
FROM (
    SELECT
        genre,
        COUNT(movie_id) AS movie_count
    FROM
        amitdb.genre
    GROUP BY
        genre
) AS genre_counts
WHERE
    genre = 'Thriller';

SELECT * FROM amitdb.ratings;

-- - (a) Retrieve the minimum and maximum values in each column of the ratings table (except movie_id).
SELECT
    MIN(avg_rating) AS min_avg_rating,
    MAX(avg_rating) AS max_avg_rating,
    MIN(total_votes) AS min_total_votes,
    MAX(total_votes) AS max_total_votes,
    MIN(median_rating) AS min_median_rating,
    MAX(median_rating) AS max_median_rating
FROM amitdb.ratings;

-- (b) Identify the top 10 movies based on average rating.

SELECT *
FROM amitdb.ratings
ORDER BY avg_rating DESC
LIMIT 10;

-- (c) Summarise the ratings table based on movie counts by median ratings.

SELECT
    median_rating,
    COUNT(*) AS movie_count
FROM amitdb.ratings
GROUP BY median_rating;

-- (d) Identify the production house that has produced the most number of hit movies (average rating > 8).

SELECT
    m.production_company,
    COUNT(*) AS hit_movie_count
FROM amitdb.ratings r
JOIN amitdb.movies m ON r.movie_id = m.id
WHERE r.avg_rating > 8
GROUP BY m.production_company
ORDER BY hit_movie_count DESC
LIMIT 1;

-- 	Determine the number of movies released in each genre during March 2017 in the USA with more than 1,000 votes.

SELECT
    g.genre,
    COUNT(*) AS movie_count
FROM amitdb.genre g
JOIN amitdb.ratings r ON g.movie_id = r.movie_id
JOIN amitdb.movies m ON r.movie_id = m.id
WHERE m.country = 'USA'
    AND m.year = 2017
    AND r.total_votes > 1000
GROUP BY g.genre;

-- -	Retrieve movies of each genre starting with the word 'The' and having an average rating > 8.

SELECT
    g.genre,
    m.title,
    r.avg_rating
FROM amitdb.genre g
JOIN amitdb.ratings r ON g.movie_id = r.movie_id
JOIN amitdb.movies m ON r.movie_id = m.id
WHERE g.genre LIKE 'The%'
    AND r.avg_rating > 8;


-- 	Identify the columns in the names table that have null values.

SELECT
    id,
    name,
    height,
    date_of_birth,
    known_for_movies
FROM amitdb.names
WHERE id IS NULL OR name IS NULL OR height IS NULL OR date_of_birth IS NULL OR known_for_movies IS NULL;

-- Determine the top three directors in the top three genres with movies having an average rating > 8.

SELECT
    g.genre,
    d.name_id,
    COUNT(*) AS movie_count
FROM amitdb.genre g
JOIN amitdb.director_mapping d ON g.movie_id = d.movie_id
JOIN amitdb.movies m ON g.movie_id = m.id
JOIN amitdb.ratings r ON m.id = r.movie_id
WHERE r.avg_rating > 8
GROUP BY g.genre, d.name_id
ORDER BY movie_count DESC
LIMIT 3;

-- Find the top two actors whose movies have a median rating >= 8.

SELECT
    g.genre,
    d.name_id,
    COUNT(*) AS movie_count
FROM amitdb.genre g
JOIN amitdb.director_mapping d ON g.movie_id = d.movie_id
JOIN amitdb.movies m ON g.movie_id = m.id
JOIN amitdb.ratings r ON m.id = r.movie_id
WHERE r.avg_rating > 8
GROUP BY g.genre, d.name_id
ORDER BY movie_count DESC
LIMIT 3;

-- Identify the top three production houses based on the number of votes received by their movies.

SELECT
    m.production_company,
    SUM(r.total_votes) AS total_votes
FROM amitdb.movies m
JOIN amitdb.ratings r ON m.id = r.movie_id
GROUP BY m.production_company
ORDER BY total_votes DESC
LIMIT 3;

-- Rank actors based on their average ratings in Indian movies released in India.

SELECT
    a.category,
    AVG(r.avg_rating) AS average_rating
FROM amitdb.role_mapping a
JOIN amitdb.movies m ON a.movie_id = m.id
JOIN amitdb.ratings r ON a.movie_id = r.movie_id
WHERE m.country = 'India'
GROUP BY a.category
ORDER BY average_rating DESC;

-- Identify the top five actresses in Hindi movies released in India based on their average ratings.

SELECT
    nm.name AS actress,
    AVG(r.avg_rating) AS average_rating
FROM amitdb.role_mapping rm
JOIN amitdb.movies m ON rm.movie_id = m.id
JOIN amitdb.ratings r ON rm.movie_id = r.movie_id
JOIN amitdb.names nm ON rm.name_id = nm.id
WHERE m.country = 'India' AND m.languages LIKE '%Hindi%' AND rm.category = 'actress'
GROUP BY nm.name
ORDER BY average_rating DESC
LIMIT 5;

-- Classify thriller movies based on average ratings into different categories.

SELECT
    title,
    avg_rating,
    CASE
        WHEN avg_rating >= 9.0 THEN 'Excellent'
        WHEN avg_rating >= 8.0 AND avg_rating < 9.0 THEN 'Very Good'
        WHEN avg_rating >= 7.0 AND avg_rating < 8.0 THEN 'Good'
        WHEN avg_rating >= 6.0 AND avg_rating < 7.0 THEN 'Average'
        ELSE 'Below Average'
    END AS rating_category
FROM amitdb.movies m
JOIN amitdb.genre g ON m.id = g.movie_id
JOIN amitdb.ratings r ON m.id = r.movie_id
WHERE g.genre = 'Thriller';


-- (b)	analyse the genre-wise running total and moving average of the average movie duration.

SELECT
    genre,
    year,
    average_duration,
    SUM(average_duration) OVER (PARTITION BY genre ORDER BY year) AS running_total_duration,
    AVG(average_duration) OVER (PARTITION BY genre ORDER BY year ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS moving_average_duration
FROM (
    SELECT
        g.genre,
        m.year,
        AVG(m.duration) AS average_duration
    FROM amitdb.movies m
    JOIN amitdb.genre g ON m.id = g.movie_id
    GROUP BY g.genre, m.year
) AS genre_avg
ORDER BY genre, year;


-- (c)	Identify the five highest-grossing movies of each year that belong to the top three genres.

SELECT
    year,
    genre,
    title,
    worlwide_gross_income
FROM (
    SELECT
        m.year,
        g.genre,
        m.title,
        m.worlwide_gross_income,
        ROW_NUMBER() OVER (PARTITION BY m.year, g.genre ORDER BY m.worlwide_gross_income DESC) AS ranking
    FROM amitdb.movies m
    JOIN amitdb.genre g ON m.id = g.movie_id
    WHERE g.genre IN ('Thriller', 'Fantasy', 'Drama')  -- Adjust genres as needed
) AS ranked_movies
WHERE ranking <= 5
ORDER BY year, genre, ranking;

-- (d)	Determine the top two production houses that have produced the highest number of hits among multilingual movies.

SELECT
    production_company,
    COUNT(*) AS hit_movie_count
FROM (
    SELECT
        m.production_company,
        r.avg_rating
    FROM amitdb.movies m
    JOIN amitdb.ratings r ON m.id = r.movie_id
    WHERE m.languages IS NOT NULL
      AND r.avg_rating > 8
) AS hits
GROUP BY production_company
ORDER BY hit_movie_count DESC
LIMIT 2;

-- (e)	Identify the top three actresses based on the number of Super Hit movies (average rating > 8) in the drama genre.

SELECT
    a.name_id,
    n.name,
    COUNT(*) AS super_hit_count
FROM amitdb.role_mapping a
JOIN amitdb.ratings r ON a.movie_id = r.movie_id
JOIN amitdb.names n ON a.name_id = n.id
WHERE a.category = 'actress'
  AND r.avg_rating > 8
  AND a.movie_id IN (
      SELECT movie_id
      FROM amitdb.genre
      WHERE genre = 'Drama'
  )
GROUP BY a.name_id, n.name
ORDER BY super_hit_count DESC
LIMIT 3;

-- (f)	Retrieve details for the top nine directors based on the number of movies, including average inter-movie duration, ratings, and more.

SELECT
    dm.name_id AS director_id,
    COUNT(DISTINCT dm.movie_id) AS movie_count,
    AVG(m.duration) AS avg_duration,
    AVG(r.avg_rating) AS avg_rating
FROM
    amitdb.director_mapping dm
JOIN
    amitdb.movies m ON dm.movie_id = m.id
JOIN
    amitdb.ratings r ON dm.movie_id = r.movie_id
GROUP BY
    dm.name_id
ORDER BY
    movie_count DESC
LIMIT 9;
