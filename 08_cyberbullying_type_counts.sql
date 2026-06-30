-- Baseline: count of tweets per cyberbullying category (used for Chart 1 - distribution)
SELECT
  cyberbullying_type,
  COUNT(tweet_text) AS count_of_tweets
FROM
  `twitter-cyberbulling`.`cyberbulling_analytics`.`Cyberbullying_Twitter_Comments`
GROUP BY
  cyberbullying_type
ORDER BY
  COUNT(tweet_text) DESC;
