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

/* Answer:
Customer A spent $76.
Customer B spent $74.
Customer C spent $36. */ 


-- 2. How many days has each customer visited the restaurant?
SELECT sales.customer_id,
       COUNT(DISTINCT order_date) AS number_of_visits
FROM dannys_diner.sales
GROUP BY customer_id;

/* Answer:
Customer A visited 4 days.
Customer B visited 6 days.
Customer C visited 2 days. */ 


-- 3. What was the first item from the menu purchased by each customer?
SELECT DISTINCT customer_id,
                order_date,
                product_name
FROM dannys_diner.menu
INNER JOIN dannys_diner.sales AS s USING(product_id)
ORDER BY s.order_date,
         s.customer_id
LIMIT 4;

/* Answer:
Customer A’s first item ordered from the menu is curry and sushi. Talk about an appetite!
Customer B’s first item ordered from the menu is curry.
Customer C’s first item ordered from the menu is ramen. */ 


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT product_name,
       COUNT(*) AS times_purchased
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu USING (product_id)
GROUP BY product_name
ORDER BY times_purchased DESC
LIMIT 1;

/* Answer:
Ramen is the most purchased item on the menu, and it was purchased 8 times. Ramen is so delicious!*/ 


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

/* Answer:
Ramen is the most popular item for customer A and C.
Customer B equally likes the curry, ramen, and sushi. */ 


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

/* Answer:
Customer A’s first item purchased after becoming a member is curry.
Customer B’s first item purchased after becoming a member is sushi.*/ 


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

/* Answer:
Customer B’s menu item purchased just before becoming a member is sushi. This customer really loves Danny’s sushi!
Customer A’s menu item purchased just before becoming a member are sushi and curry. */ 


-- 8. What is the total items and amount spent for each member before they became a member?
SELECT sales.customer_id AS customer,
       SUM(menu.price) AS total_spent,
       COUNT(DISTINCT menu.product_id) AS number_of_different_menu_items
FROM dannys_diner.sales
INNER JOIN dannys_diner.members USING(customer_id)
INNER JOIN dannys_diner.menu USING(product_id)
WHERE sales.order_date < members.join_date
GROUP BY sales.customer_id;

/* Answer:
Customer A purchased 2 items and spent $25.
Customer B purchased 2 items and spent $40 */ 


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

/* Answer:
Customer A has a total of 860 points earned.
Customer B has a total of 940 points earned.
Customer C has a total of 360 points earned. */ 


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT s.customer_id,
SELECT s.customer_id,
       SUM(CASE
               WHEN product_name = 'sushi' THEN 20*(price)
               WHEN s.order_date BETWEEN join_date AND join_date + 6 THEN 20*(price)
               ELSE 10*(price)
           END)as customer_points
FROM dannys_diner.menu m
JOIN dannys_diner.sales s ON m.product_id = s.product_id
JOIN dannys_diner.members c ON c.customer_id = s.customer_id
WHERE s.order_date < '2021-01-31'
GROUP BY 1 

/* Answer:
Customer A has a total of 1370 points earned.
Customer B has a total of 820 points earned. */
