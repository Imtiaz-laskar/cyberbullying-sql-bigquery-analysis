-- Compare average likes, replies, and shares across cyberbullying categories
SELECT
  cyberbullying_type,
  AVG(num_likes) AS average_num_likes,
  AVG(num_replies) AS average_num_replies,
  AVG(num_shares) AS average_num_shares
FROM
  `twitter-cyberbulling`.`cyberbulling_analytics`.`Cyberbullying_Twitter_Comments`
GROUP BY
  cyberbullying_type
ORDER BY
  AVG(num_likes) DESC;
