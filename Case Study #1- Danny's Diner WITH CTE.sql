/*-----------------------
 The Three Key Tables in this dataset are
-------------------------*/ -- Sales
-- Menu
-- Members
 /* --------------------
   Case Study Questions
   --------------------*/ -- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
 -- Question 1: What is the total amount each customer spent at the restaurant?

SELECT customer_id AS customer,
       SUM(price) AS total_amount
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu USING(product_id)
GROUP BY customer_id
ORDER BY total_amount desc;

--QUESTION 2: How many days has each customer visited the restaurant?

SELECT customer_id,
       COUNT(distinct(order_date)) AS no_of_days
FROM dannys_diner.sales
GROUP BY customer_id
ORDER BY no_of_days desc;

--QUESTION 3: What was the first item from the menu purchased by each customer?
WITH first_sales_cte AS
    ( SELECT customer_id,
             order_date,
             product_name,
             ROW_NUMBER() OVER(PARTITION BY s.customer_id
                               ORDER BY s.order_date) AS row_number
     FROM dannys_diner.sales AS s
     INNER JOIN dannys_diner.menu m ON s.product_id = m.product_id)
SELECT customer_id,
       product_name
FROM first_sales_cte
WHERE row_number = 1
GROUP BY customer_id,
         product_name;

--QUESTION 4: What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT product_name,
       COUNT(sales.product_id) AS most_purchased_item
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu USING(product_id)
GROUP BY product_name
ORDER BY most_purchased_item desc
LIMIT 1 --QUESTION 5: Which item was the most popular for each customer?
WITH item_bought_cte AS
    ( SELECT customer_id,
             product_name,
             COUNT(*) AS times_purchased
     FROM dannys_diner.sales
     INNER JOIN dannys_diner.menu USING (product_id)
     GROUP BY customer_id,
              product_name
     ORDER BY customer_id,
              times_purchased DESC)
SELECT customer_id,
       product_name
FROM
    ( SELECT ib.*,
             ROW_NUMBER() OVER (PARTITION BY customer_id
                                ORDER BY times_purchased DESC) AS row_number
     FROM item_bought_cte AS ib) AS temp
WHERE row_number = 1; --QUESTION 6: Which item was purchased first by the customer after they became a member?

WITH purchased_first_cte AS
    ( SELECT sales.customer_id,
             product_name,
             order_date,
             ROW_NUMBER() OVER(PARTITION BY sales.customer_id
                               ORDER BY order_date)
     FROM dannys_diner.sales
     INNER JOIN dannys_diner.members USING(customer_id)
     INNER JOIN dannys_diner.menu USING(product_id)
     WHERE order_date >= join_date )
SELECT customer_id,
       product_name,
       order_date
FROM purchased_first_cte
WHERE ROW_NUMBER=1