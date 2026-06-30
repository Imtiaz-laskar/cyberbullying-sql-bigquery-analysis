-- Data quality check: inspect rows with a missing date_posted value
SELECT
  tweet_text,
  cyberbullying_type,
  date_posted
FROM
  `twitter-cyberbulling`.`cyberbulling_analytics`.`Cyberbullying_Twitter_Comments`
WHERE
  date_posted IS NULL
LIMIT
  20;
