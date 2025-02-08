-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

-- EDA
select count(*) from spotify;


/*
-- ------------------------------
-- Data Analysis -Easy Category
-- ------------------------------

Q1. Retrieve the names of all tracks that have more than 1 billion streams.
Q2. List all albums along with their respective artists.
Q3. Get the total number of comments for tracks where licensed = TRUE.
Q4. Find all tracks that belong to the album type single.
Q5. Count the total number of tracks by each artist.

*/

-- Q.1 Retrieve the names of all tracks that have more than 1 billion streams.

SELECT *
FROM SPOTIFY
where stream > '1000000000';

-- Q2. List all albums along with their respective artists.

select distinct
       album,
	   artist
from spotify;

-- Q3. Get the total number of comments for tracks where licensed = TRUE.

select sum(comments) as total_comments
from spotify
where licensed = 'true';

-- Q4. Find all tracks that belong to the album type single.

select *
from spotify
where album_type = 'single';

-- Q5. Count the total number of tracks by each artist.

select artist,
        count(*) as total_number_of_track
from spotify
group by artist;

/*
-- --------------------
Medium Level
-- --------------------

Q.6 Calculate the average danceability of tracks in each album.
Q.7 Find the top 5 tracks with the highest energy values.
Q.8 List all tracks along with their views and likes where official_video = TRUE.
Q.9 For each album, calculate the total views of all associated tracks.
Q.10 Retrieve the track names that have been streamed on Spotify more than YouTube.
*/

-- Q.6 Calculate the average danceability of tracks in each album.

SELECT album,
       avg(danceability) as average_danceabilty
FROM SPOTIFY
group by album
order by 2 desc;

-- Q.7 Find the top 5 tracks with the highest energy values.

select  track,
        max(energy)
from spotify
group by 1
order by 2 desc
limit 5;

-- Q.8 List all tracks along with their views and likes where official_video = TRUE.

select track,
        sum(views) as total_views,
		sum(likes) as total_likes
from spotify
where official_video = 'true'
group by track
order by 2 desc;

-- Q.9 For each album, calculate the total views of all associated tracks.

select 
       album,
	   track,
	   sum(views) as total_views
from spotify
group by 1,2
order by 3 desc


-- Q.10 Retrieve the track names that have been streamed on Spotify more than YouTube.

with cte as (
    select track,
		coalesce (sum(case when most_played_on = 'Youtube' then stream end),0) as streamed_on_youtube,
		coalesce(sum(case when most_played_on = 'Spotify' then stream end),0) as streamed_on_spotify
    from spotify
    group by 1)
select *
from cte where streamed_on_youtube<streamed_on_spotify
         and
		 streamed_on_youtube<>0
	

/*
-- --------------------
Hard Level
-- --------------------   

Q.11 Find the top 3 most-viewed tracks for each artist using window functions.
Q.12 Write a query to find tracks where the liveness score is above the average.
Q.13 Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
Q.14 Find tracks where the energy-to-liveness ratio is greater than 1.2.
Q.15 Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
*/

-- Q.11 Find the top 3 most-viewed tracks for each artist using window functions.
with cte as
     (select artist,
	         track,
            sum(views) as total_view
     from spotify
	 group by 1,2),
final_cte as (	 
select track,
       artist,
	    dense_rank() over(partition by artist order by total_view desc) as top_songs
from cte)
select *
from final_cte
where top_songs<=3;


-- Q.12 Write a query to find tracks where the liveness score is above the average.

  select track,
	   liveness,
	   artist
  from spotify
  where liveness > (select avg(liveness) from spotify)
  
-- Q.3 Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.

with cte as 
(
select album,
       -- track,
       max(energy) as highest_energy,
	    min(energy) as lowest_energy 
from spotify
group by album
)
select   album,
         (highest_energy-lowest_energy) as energy_difference
from cte 
order by 2 desc;

-- Q.14 Find tracks where the energy-to-liveness ratio is greater than 1.2 .

SELECT track,
        energy/liveness
from spotify
where liveness<>0 and energy<>0
group by track,energy,liveness
order by 2 desc

-- Q.15 Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
