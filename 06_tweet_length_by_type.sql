-- Compare average tweet length across cyberbullying categories (strongest finding in this project)
SELECT
  cyberbullying_type,
  AVG(tweet_length) AS average_tweet_length
FROM
  `twitter-cyberbulling`.`cyberbulling_analytics`.`Cyberbullying_Twitter_Comments`
GROUP BY
  cyberbullying_type
ORDER BY
  AVG(tweet_length) DESC;
