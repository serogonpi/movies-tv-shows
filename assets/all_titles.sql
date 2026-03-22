/* @bruin
name: movies_tv_shows.all_titles
type: bq.sql
materialization:
    type: table
    strategy: create+replace
    partition_by: RANGE_BUCKET(release_year, GENERATE_ARRAY(1900, 2030, 10))
    cluster_by:
        - platform
        - type
depends:
    - movies_tv_shows.raw_hulu
    - movies_tv_shows.raw_netflix
    - movies_tv_shows.raw_amazon
    - movies_tv_shows.raw_disney_plus
@bruin */

WITH deduplicated AS(
    SELECT
    show_id,
    type,
    title,
    COALESCE(director, 'Unknown') AS director,
    COALESCE(n.cast, 'Unknown') AS casting,
    COALESCE(country, 'Unknown') AS country,
    date_added,
    release_year,
    COALESCE(rating, 'Not Rated') AS rating,
    duration,
    listed_in,
    description,
    'netflix' AS platform
    FROM movies_tv_shows.raw_netflix AS n

    UNION ALL

    SELECT
    show_id,
    type,
    title,
    COALESCE(director, 'Unknown') AS director,
    COALESCE(a.cast, 'Unknown') AS casting,
    COALESCE(country, 'Unknown') AS country,
    date_added,
    release_year,
    COALESCE(rating, 'Not Rated') AS rating,
    duration,
    listed_in,
    description,
    'amazon_plus' AS platform
    FROM `movies_tv_shows.raw_amazon` AS a

    UNION ALL

    SELECT
    show_id,
    type,
    title,
    COALESCE(director, 'Unknown') AS director,
    COALESCE(d.cast, 'Unknown') AS casting,
    COALESCE(country, 'Unknown') AS country,
    date_added,
    release_year,
    COALESCE(rating, 'Not Rated') AS rating,
    duration,
    listed_in,
    description,
    'disney_plus' AS platform
    FROM `movies_tv_shows.raw_disney_plus` AS d

    UNION ALL

    SELECT
    show_id,
    type,
    title,
    COALESCE(director, 'Unknown') AS director,
    CAST(NULL AS STRING) AS casting,
    COALESCE(country, 'Unknown') AS country,
    date_added,
    release_year,
    COALESCE(rating, 'Not Rated') AS rating,
    duration,
    listed_in,
    description,
    'hulu' AS platform
    FROM `movies_tv_shows.raw_hulu` AS h
),
ranked AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY title, platform ORDER BY show_id) AS rn
    FROM deduplicated
)
SELECT * EXCEPT(rn)
FROM ranked
WHERE rn = 1

