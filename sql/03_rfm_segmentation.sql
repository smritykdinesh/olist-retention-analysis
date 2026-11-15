WITH order_pay AS (
  SELECT order_id, SUM(payment_value) AS pay
  FROM payments
  GROUP BY order_id
),
base AS (
  SELECT c.customer_unique_id,
         MAX(o.order_purchase_timestamp) AS last_order,
         COUNT(DISTINCT o.order_id) AS frequency,
         SUM(op.pay) AS monetary
  FROM orders o
  JOIN customers c ON c.customer_id = o.customer_id
  JOIN order_pay op ON op.order_id = o.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY 1
),
scored AS (
  SELECT *,
         CAST(julianday((SELECT MAX(order_purchase_timestamp) FROM orders))
              - julianday(last_order) AS INT) AS recency_days
  FROM base
),
rfm AS (
  SELECT *,
         NTILE(5) OVER (ORDER BY recency_days DESC) AS r,   -- 5 = most recent
         CASE WHEN frequency = 1 THEN 1
              WHEN frequency = 2 THEN 3
              ELSE 5 END AS f,
         NTILE(5) OVER (ORDER BY monetary) AS m
  FROM scored
)
SELECT CASE
         WHEN f >= 3 AND m >= 4                THEN 'Champions'
         WHEN f >= 3                           THEN 'Loyal'
         WHEN r >= 4 AND m >= 4                THEN 'New High-Value'
         WHEN r >= 4                           THEN 'New / Recent'
         WHEN r <= 2 AND m >= 4                THEN 'At Risk High-Value'
         WHEN r <= 2                           THEN 'Lapsed'
         ELSE 'Mid-tier One-timers'
       END AS segment,
       COUNT(*) AS customers,
       ROUND(SUM(monetary), 0) AS total_revenue,
       ROUND(AVG(monetary), 2) AS avg_spend
FROM rfm
GROUP BY 1
ORDER BY total_revenue DESC;