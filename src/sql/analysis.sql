/*
1. What is the average delivery time across different regions?
*/
SELECT 
	d.region,
    COUNT(DISTINCT o.order_id) AS no_of_orders,
    COUNT(DISTINCT o.driver_id) AS no_of_delivery_partners,
    AVG(TIMESTAMPDIFF(MINUTE, o.order_datetime, o.delivery_datetime)) AS avg_delivery_time_in_minutes
FROM orders o
LEFT JOIN driver d
ON o.driver_id = d.driver_id
WHERE o.delivery_datetime IS NOT NULL
GROUP BY d.region
ORDER BY no_of_orders DESC, avg_delivery_time_in_minutes DESC;

/* Conclusion: 
>> Mooreport, Melindaburgh and Lindseyside - Despite lower no. of orders, higher delivery time -> check with delivery partners: distance travelled could be an issue, traffic or road infra another
>> Jacobland, New Brooke, Brianshire - Despite higher no. of orders, lower delivery time -> incentivise delivery partners
>> Identifying which areas have slow or fast deliveries can help to improve driver distribution or app delivery promises.
*/
# ====================================================================================================================
/*
2. Who are the top 5 most frequent customers by order count or spending?
*/
WITH cte AS (
	SELECT customer_id,
		DENSE_RANK() OVER(ORDER BY COUNT(order_id) DESC) AS total_order_count_rank,
		DENSE_RANK() OVER(ORDER BY SUM(amount) DESC) AS total_order_amount_rank
	FROM orders
	GROUP BY customer_id
)
SELECT customer_id FROM cte WHERE total_order_count_rank <= 5
UNION ALL
SELECT '**********'
UNION ALL
SELECT customer_id FROM cte WHERE total_order_amount_rank <= 5;
/*
Conclusion: High-value customers are important for loyalty rewards or targeted marketing.
*/
# =================================================================================================================
/*
3. What are the peak hours for food orders?
*/
SELECT HOUR(order_datetime), COUNT(order_id) AS no_of_orders_placed
FROM orders
GROUP BY HOUR(order_datetime)
ORDER BY no_of_orders_placed DESC;
/*
Conclusion: Useful for surge pricing, marketing, or restaurant staffing.
*/
# ================================================================================================================
/*
4. Which restaurants have the highest failure/cancellation rates?
*/
SELECT restaurant_id,
	COUNT(order_id) AS total_order_count,
	SUM(CASE WHEN status IN ('failed', 'cancelled') THEN 1 ELSE 0 END) AS failed_cancelled_order_count,
    ROUND(100 * (SUM(CASE WHEN status IN ('failed', 'cancelled') THEN 1 ELSE 0 END)/COUNT(order_id)), 2) AS fc_percentage
FROM orders
GROUP BY restaurant_id
ORDER BY fc_percentage DESC;
/*
Conclusion: Important for service quality monitoring or offboarding poor performers.
*/
# =============================================================================================================
/*
5. What cuisines are most popular based on number of delivered orders or items sold?
*/
SELECT item_name, COUNT(order_id) AS order_count
FROM order_item
GROUP BY item_name
ORDER BY order_count DESC LIMIT 5;
/* 
Conclusion: Useful for expansion and partnership decisions.
*/
# =============================================================================================================
/*
6. What is the customer retention rate or re-order behaviour over months?
*/
WITH first_order AS (
	SELECT customer_id, 
		DATE_FORMAT(order_datetime, '%Y-%m') AS order_month, 
        MIN(DATE_FORMAT(order_datetime, '%Y-%m')) OVER(PARTITION BY customer_id) AS first_order_month
	FROM orders
),
orders_flag AS (
	SELECT *, 
		CASE WHEN order_month = first_order_month THEN 'New' ELSE 'Repeat' END AS new_old_flag
	FROM first_order
)
SELECT order_month,
	COUNT(DISTINCT CASE WHEN new_old_flag = 'New' THEN customer_id END) AS New_Customer,
    COUNT(DISTINCT CASE WHEN new_old_flag = 'Repeat' THEN customer_id END) AS Repeat_Customer,
    COUNT(DISTINCT customer_id) AS Total_Customer
FROM orders_flag
GROUP BY order_month
ORDER BY order_month;

# Calculate Customer Lifetime Value (CLV/LTV): CLV = AOV × Frequency × Lifespan
# where, AOV = Average order value, Frequency = Average purchase frequency per month, Lifespan = Average customer lifespan
WITH cte AS (
	SELECT
	  customer_id,
	  COUNT(order_id) AS total_orders,
	  ROUND(AVG(amount), 2) AS avg_order_value,
	  CAST(MIN(order_datetime) AS DATE) AS first_order,
	  CAST(MAX(order_datetime) AS DATE) AS last_order,
	  ROUND(DATEDIFF(MAX(order_datetime), MIN(order_datetime)) / 30.0, 2) AS months_active,
	  SUM(amount) AS lifetime_value,
	  ROUND(COUNT(order_id) / ROUND(DATEDIFF(MAX(order_datetime), MIN(order_datetime)) / 30.0, 2), 2) AS avg_monthly_order_count
	FROM orders
	WHERE status = 'delivered'
	GROUP BY customer_id
)
SELECT *, 
	IFNULL(ROUND(avg_order_value*months_active*avg_monthly_order_count, 2), 0) AS customer_lifetime_value
FROM cte
ORDER BY customer_lifetime_value DESC;
/*
Conclusion: Helps assess customer lifetime value and satisfaction.
*/
# ==========================================================================================================
/*
7. Are there specific regions or restaurants driving unusually high demand in recent months (demand spikes)?
*/
WITH monthly_orders AS (
  SELECT
    restaurant_id,
    DATE_FORMAT(order_datetime, '%Y-%m') AS order_month,
    COUNT(*) AS monthly_order_count
  FROM orders
  WHERE status = 'delivered'
    AND order_datetime >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
  GROUP BY restaurant_id, order_month
),
avg_baseline AS (
  SELECT
    restaurant_id,
    AVG(monthly_order_count) AS avg_orders_last_months
  FROM monthly_orders
  WHERE order_month < DATE_FORMAT(STR_TO_DATE('2025-07-31','%Y-%m-%d'), '%Y-%m') # should be CURRENT_DATE
  GROUP BY restaurant_id
),
recent_month AS (
  SELECT
    restaurant_id,
    monthly_order_count AS recent_orders
  FROM monthly_orders
  WHERE order_month = DATE_FORMAT(STR_TO_DATE('2025-07-31','%Y-%m-%d'), '%Y-%m') # should be CURRENT_DATE
)
SELECT
  r.restaurant_id,
  r.recent_orders,
  ROUND(a.avg_orders_last_months, 2) AS avg_orders_last_months,
  ROUND(r.recent_orders / a.avg_orders_last_months, 1) AS demand_spike_ratio
FROM recent_month r
JOIN avg_baseline a ON r.restaurant_id = a.restaurant_id
WHERE (r.recent_orders / a.avg_orders_last_months) > 1.5 # let's say threshold for spike = 1.5
ORDER BY demand_spike_ratio DESC;
/*
Conclusion: Useful for forecasting demand and optimizing driver/restaurant operations.
*/

