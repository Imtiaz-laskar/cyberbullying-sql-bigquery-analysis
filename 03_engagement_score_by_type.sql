-- Cross-validate engagement findings using the composite engagement_score column
SELECT
  cyberbullying_type,
  AVG(engagement_score) AS average_engagement_score
FROM
  `twitter-cyberbulling`.`cyberbulling_analytics`.`Cyberbullying_Twitter_Comments`
GROUP BY
  cyberbullying_type
ORDER BY
  AVG(engagement_score) DESC;
