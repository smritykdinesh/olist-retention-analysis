WITH rev AS (
  SELECT order_id, AVG(review_score) AS score
  FROM reviews
  GROUP BY order_id
)
SELECT CASE
         WHEN julianday(o.order_delivered_customer_date)
              <= julianday(o.order_estimated_delivery_date)            THEN '1. On time'
         WHEN julianday(o.order_delivered_customer_date)
              - julianday(o.order_estimated_delivery_date) <= 3        THEN '2. 1-3 days late'
         WHEN julianday(o.order_delivered_customer_date)
              - julianday(o.order_estimated_delivery_date) <= 7        THEN '3. 4-7 days late'
         ELSE '4. 8+ days late'
       END AS delivery_bucket,
       COUNT(*) AS orders,
       ROUND(AVG(r.score), 2) AS avg_review,
       ROUND(100.0 * AVG(r.score <= 2), 1) AS pct_bad_reviews
FROM orders o
JOIN rev r ON r.order_id = o.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY 1
ORDER BY 1;