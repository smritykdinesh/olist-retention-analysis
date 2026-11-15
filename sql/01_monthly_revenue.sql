WITH monthly AS (
  SELECT strftime('%Y-%m', o.order_purchase_timestamp) AS month,
         COUNT(DISTINCT o.order_id) AS orders,
         SUM(oi.price) AS revenue
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  WHERE o.order_status = 'delivered'
    AND o.order_purchase_timestamp >= '2017-01-01'
    AND o.order_purchase_timestamp <  '2018-09-01'
  GROUP BY 1
)
SELECT month,
       orders,
       ROUND(revenue, 2) AS revenue,
       ROUND(revenue * 1.0 / orders, 2) AS aov,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
             / LAG(revenue) OVER (ORDER BY month), 1) AS mom_growth_pct
FROM monthly
ORDER BY month;