-- SQL Mini Project 
-- SQL Mentor User Performance

    CREATE TABLE user_submissions (
    id SERIAL PRIMARY KEY,
    user_id BIGINT,
    question_id INT,
    points INT,
    submitted_at TIMESTAMP WITH TIME ZONE,
    username VARCHAR(50)
);

SELECT * FROM user_submissions;

-- Q.1 List all distinct users and their stats (return user_name, total_submissions, points earned)
-- Q.2 Calculate the daily average points for each user.
-- Q.3 Find the top 3 users with the most positive submissions for each day.
-- Q.4 Find the top 5 users with the highest number of incorrect submissions.
-- Q.5 Find the top 10 performers for each week.


-- Please note for each questions return current stats for the users
-- user_name, total points earned, correct submissions, incorrect submissions no


--------------
--SOLUTIONS--
--------------

-- Q.1 List all distinct users and their stats (return user_name, total_submissions, points earned)


SELECT username,
       SUM(points) AS points_earned,
       COUNT(id) AS total_submissions
FROM user_submissions
       GROUP BY username
       ORDER BY total_submissions DESC;

-- Q.2 Calculate the daily average points for each user.


SELECT 
       TO_CHAR (submitted_at,'DD-MM') AS Date,
	   username,
       ROUND(AVG(points),2) AS avg_daily_points
FROM user_submissions
       GROUP BY Date,username
       ORDER BY username;

-- Q.3 Find the top 3 users with the most positive submissions for each day.


WITH daily_submissions
AS
(
SELECT 
       TO_CHAR (submitted_at,'DD-MM') AS Daily,
	   username,
	   SUM(CASE 
	       WHEN points>0 THEN 1 ELSE 0
		   END) AS correct_submissions 
FROM user_submissions
       GROUP BY Daily,username
),
users_rank
AS
(SELECT 
	daily,
	username,
	correct_submissions,
	DENSE_RANK() OVER(PARTITION BY daily ORDER BY correct_submissions DESC) AS rank
FROM daily_submissions
)

SELECT 
	daily,
	username,
	correct_submissions
FROM users_rank
WHERE rank <= 3;

-- Q.4 Find the top 5 users with the highest number of incorrect submissions.


SELECT 
       username,
	       SUM(CASE 
	       WHEN points<0 THEN 1 ELSE 0
		   END) AS incorrect_submissions,
		   
		   SUM(CASE 
	       WHEN points>0 THEN 1 ELSE 0
		   END) AS correct_submissions, 
		   
		   SUM(CASE 
	       WHEN points>0 THEN points ELSE 0
		   END) AS correct_submissions_points_earned,
		   
		   SUM(CASE 
	       WHEN points<0 THEN points ELSE 0
		   END) AS incorrect_submissions_points_earned,

		   SUM(points) AS points_earned

FROM user_submissions
       GROUP BY username
	   ORDER BY incorrect_submissions DESC
	   LIMIT 5;

-- Q.5 Find the top 10 performers for each week.


SELECT * FROM
(
	SELECT 
		EXTRACT(WEEK FROM submitted_at) AS week_no,
		username,
		SUM(points) as total_points_earned,
		DENSE_RANK() OVER(PARTITION BY EXTRACT(WEEK FROM submitted_at) 
		ORDER BY SUM(points) DESC) AS rank
	FROM user_submissions
	GROUP BY 1, 2
	ORDER BY week_no, total_points_earned DESC
)
WHERE rank <= 10






