-- For each year, find the harmful category (excluding not_cyberbullying) with the highest tweet count
SELECT
  EXTRACT(YEAR
  FROM
    t0.date_posted) AS year_posted,
  t0.cyberbullying_type,
  COUNT(t0.tweet_text) AS count_of_tweets
FROM
  `twitter-cyberbulling`.`cyberbulling_analytics`.`Cyberbullying_Twitter_Comments` AS t0
WHERE
  t0.cyberbullying_type != 'not_cyberbullying'
GROUP BY
  year_posted,
  t0.cyberbullying_type
QUALIFY
  ROW_NUMBER() OVER (PARTITION BY year_posted ORDER BY COUNT(t0.tweet_text) DESC) = 1
ORDER BY
  year_posted;
