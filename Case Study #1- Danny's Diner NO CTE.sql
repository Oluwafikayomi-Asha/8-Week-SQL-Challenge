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
 -- 1. What is the total amount each customer spent at the restaurant?

SELECT SUM(price) AS total_amount,
       customer_id
FROM dannys_diner.menu
INNER JOIN dannys_diner.sales USING(product_id)
GROUP BY customer_id
ORDER BY total_amount DESC;

-- 2. How many days has each customer visited the restaurant?

SELECT sales.customer_id,
       COUNT(DISTINCT order_date) AS number_of_visits
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?

SELECT DISTINCT customer_id,
                order_date,
                product_name
FROM dannys_diner.menu
INNER JOIN dannys_diner.sales AS s USING(product_id)
ORDER BY s.order_date,
         s.customer_id
LIMIT 4;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT pizza_names.pizza_name,
       COUNT(customer_orders.order_id)
FROM pizza.runner_orders
INNER JOIN pizza.customer_orders ON runner_orders.order_id = customer_orders.order_id
INNER JOIN pizza.pizza_names ON pizza_names.pizza_id = customer_orders.pizza_id
WHERE CAST (runner_orders.distance_in_km AS FLOAT) !=0
GROUP BY pizza_names.pizza_name;

-- 5. Which item was the most popular for each customer?

SELECT sales.customer_id,
       menu.product_name,
       COUNT(menu.product_id) AS number_of_purchases
FROM dannys_diner.menu
INNER JOIN dannys_diner.sales USING(product_id)
GROUP BY menu.product_name,
         sales.customer_id
ORDER BY number_of_purchases DESC
LIMIT 6;

-- 6. Which item was purchased first by the customer after they became a member?

SELECT DISTINCT members.join_date,
                sales.customer_id,
                sales.order_date,
                menu.product_name
FROM dannys_diner.sales
INNER JOIN dannys_diner.members USING(customer_id)
INNER JOIN dannys_diner.menu USING(product_id)
WHERE sales.order_date >= members.join_date
ORDER BY sales.order_date DESC,
         members.join_date
OFFSET 3;

-- 7. Which item was purchased just before the customer became a member?

SELECT DISTINCT members.join_date,
                sales.customer_id,
                sales.order_date,
                menu.product_name
FROM dannys_diner.sales
INNER JOIN dannys_diner.members USING(customer_id)
INNER JOIN dannys_diner.menu USING(product_id)
WHERE sales.order_date < members.join_date
ORDER BY sales.order_date DESC,
         members.join_date
LIMIT 4;

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT sales.customer_id AS customer,
       SUM(menu.price) AS total_spent,
       COUNT(DISTINCT menu.product_id) AS number_of_different_menu_items
FROM dannys_diner.sales
INNER JOIN dannys_diner.members USING(customer_id)
INNER JOIN dannys_diner.menu USING(product_id)
WHERE sales.order_date < members.join_date
GROUP BY sales.customer_id;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT sales.customer_id,
       SUM(CASE
               WHEN menu.product_name = 'sushi' THEN menu.price * 20
               WHEN menu.product_name = 'curry' THEN menu.price * 10
               WHEN menu.product_name = 'ramen' THEN menu.price * 10
           END) AS points_earned
FROM dannys_diner.menu
INNER JOIN dannys_diner.sales USING(product_id)
GROUP BY sales.customer_id
ORDER BY sales.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT members.customer_id AS customer,
       SUM(CASE
               WHEN members.customer_id = 'A'
                    AND sales.order_date BETWEEN '2021-01-07' AND '2021-01-13' THEN menu.price * 20
               WHEN members.customer_id = 'B'
                    AND sales.order_date BETWEEN '2021-01-09' AND '2021-01-15' THEN menu.price * 20
               WHEN menu.product_name = 'sushi' THEN menu.price * 20
               ELSE menu.price * 10
           END) AS total_points
FROM dannys_diner.sales
INNER JOIN dannys_diner.members USING(customer_id)
INNER JOIN dannys_diner.menu USING(product_id)
WHERE sales.order_date BETWEEN '2020-01-01' AND '2020-01-31'
GROUP BY members.customer_id
ORDER BY members.customer_id;