WITH cust_orders AS (
  SELECT c.customer_unique_id,
         strftime('%Y-%m', o.order_purchase_timestamp) AS order_month,
         CAST(strftime('%Y', o.order_purchase_timestamp) AS INT) * 12
           + CAST(strftime('%m', o.order_purchase_timestamp) AS INT) AS month_num
  FROM orders o
  JOIN customers c ON c.customer_id = o.customer_id
  WHERE o.order_status = 'delivered'
),
cohorts AS (
  SELECT customer_unique_id,
         MIN(order_month) AS cohort_month,
         MIN(month_num)   AS cohort_num
  FROM cust_orders
  GROUP BY customer_unique_id
)
SELECT ch.cohort_month,
       co.month_num - ch.cohort_num AS months_since_first,
       COUNT(DISTINCT co.customer_unique_id) AS active_customers
FROM cust_orders co
JOIN cohorts ch ON ch.customer_unique_id = co.customer_unique_id
GROUP BY 1, 2
ORDER BY 1, 2;