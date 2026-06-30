-- Explore whether self-reported user location shows any concentration by cyberbullying type
SELECT
  user_location,
  cyberbullying_type,
  COUNT(*) AS tweet_count
FROM
  `twitter-cyberbulling`.`cyberbulling_analytics`.`Cyberbullying_Twitter_Comments`
WHERE
  user_location IS NOT NULL
  AND user_location != ''
GROUP BY
  user_location,
  cyberbullying_type
ORDER BY
  COUNT(*) DESC
LIMIT
  20;
