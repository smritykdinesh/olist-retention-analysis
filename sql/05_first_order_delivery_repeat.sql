WITH ordered AS (
  SELECT c.customer_unique_id,
         o.order_purchase_timestamp,
         o.order_delivered_customer_date,
         o.order_estimated_delivery_date,
         ROW_NUMBER() OVER (PARTITION BY c.customer_unique_id
                            ORDER BY o.order_purchase_timestamp) AS rn,
         COUNT(*) OVER (PARTITION BY c.customer_unique_id) AS total_orders
  FROM orders o
  JOIN customers c ON c.customer_id = o.customer_id
  WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
),
first_orders AS (
  SELECT *,
         CASE
           WHEN julianday(order_delivered_customer_date)
                <= julianday(order_estimated_delivery_date)           THEN '1. On time'
           WHEN julianday(order_delivered_customer_date)
                - julianday(order_estimated_delivery_date) <= 3       THEN '2. 1-3 days late'
           WHEN julianday(order_delivered_customer_date)
                - julianday(order_estimated_delivery_date) <= 7       THEN '3. 4-7 days late'
           ELSE '4. 8+ days late'
         END AS delivery_bucket
  FROM ordered
  WHERE rn = 1
    AND order_purchase_timestamp < '2018-03-01'
)
SELECT delivery_bucket,
       COUNT(*) AS customers,
       ROUND(100.0 * AVG(total_orders > 1), 2) AS repeat_rate_pct
FROM first_orders
GROUP BY 1
ORDER BY 1;