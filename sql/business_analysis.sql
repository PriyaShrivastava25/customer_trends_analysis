-- 1. Gender-wise Revenue Analysis
SELECT 
   gender, 
   SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY gender;

-- 2. Identification of Discount Users with Above-Average Purchase Amounts
SELECT 
	DISTINCT customer_id,
	purchase_amount
FROM customer
WHERE discount_applied = 'Yes'
  AND purchase_amount > (
      SELECT AVG(purchase_amount)
      FROM customer
  );
  
-- 3. Top 5 Products by Average Review Rating
SELECT 
	item_purchased, 
	ROUND(AVG(review_rating),2) AS avg_review_rating
FROM customer
GROUP BY item_purchased
ORDER BY avg_review_rating DESC
LIMIT 5;

-- 4. Comparison of Average Purchase Amount by Shipping Type
SELECT 
	shipping_type, 
	AVG(purchase_amount) AS avg_purchase_amount
FROM customer
GROUP BY shipping_type
HAVING shipping_type IN ('Standard', 'Express');

-- 5. Subscription Status Analysis Based on Average Spend and Total Revenue
SELECT
    subscription_status,
    COUNT(customer_id) AS total_customers,
    ROUND(AVG(purchase_amount), 2) AS avg_spend,
    ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM customer
GROUP BY subscription_status
ORDER BY total_revenue, avg_spend DESC;

-- 6. Top 5 Products by Discount Usage Percentage
SELECT 
    item_purchased, 
	COUNT(*) as total_purchases,
	SUM(CASE 
        WHEN discount_applied = 'Yes' THEN 1 
        ELSE 0 
	END) AS discounted_purchases,
    ROUND(
        100 * SUM(CASE 
			WHEN discount_applied = 'Yes' THEN 1 
			ELSE 0 
		END) / COUNT(*), 
        2)  AS discounted_pct
FROM customer
GROUP BY item_purchased
ORDER BY discounted_pct DESC
LIMIT 5;

-- 7. Customer Segmentation Based on Previous Purchase History
WITH customer_type AS (
   SELECT 
	   customer_id, 
	   previous_purchases,
	   CASE 
		 WHEN previous_purchases = 1 THEN 'New'
		 WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
		 ELSE 'Loyal'
	   END AS customer_segment
  FROM customer
)
SELECT 
	customer_segment, 
	-- COUNT(*) AS customer_count
    COUNT(DISTINCT customer_id) AS customer_count
FROM customer_type
GROUP BY customer_segment;

-- 8. Top 3 Most Purchased Products Within Each Category
WITH product_sales AS (
    SELECT
        category,
        item_purchased,
        COUNT(*) AS purchase_count
    FROM customer
    GROUP BY category, item_purchased
),
ranked_products AS (
    SELECT
        category,
        item_purchased,
        purchase_count,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY purchase_count DESC
        ) AS product_rank
    FROM product_sales
)
SELECT
    category,
    item_purchased,
    purchase_count,
    product_rank
FROM ranked_products
WHERE product_rank <= 3
ORDER BY category, product_rank;


-- 9. Subscription Distribution Among Repeat Buyers(more than 5 previous purchases)
SELECT 
	subscription_status,
	COUNT(customer_id) AS repeat_buyers
FROM customer 
WHERE previous_purchases > 5
GROUP BY subscription_status;

-- 10. Age Group-wise Revenue Analysis
SELECT 
	age_group, 
	SUM(purchase_amount) AS revenue
FROM customer
GROUP BY age_group
ORDER BY revenue DESC;

