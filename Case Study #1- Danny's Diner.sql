/*-----------------------
 The Three Key Tables in this dataset are
-------------------------
*/ 
-- Sales
-- Menu
-- Members

 /* 
 --------------------
   Case Study Questions
   -------------------- */ 
   
-- 1. What is the total amount each customer spent at the restaurant?
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
       COUNT(DISTINCT order_date) AS no_of_visits
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
         s.customer_id;

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
Ramen was purchased 8 times making it the most purchased item on the menu*/ 


-- 5. Which item was the most popular for each customer?
SELECT sales.customer_id,
       menu.product_name,
       COUNT(menu.product_id) AS most_popular_item
FROM dannys_diner.menu
INNER JOIN dannys_diner.sales USING(product_id)
GROUP BY menu.product_name,
         sales.customer_id
ORDER BY most_popular_item DESC
LIMIT 6;

/* Answer:
At 3, ramen is the most popular item for both customer A and customer C. 
customer B on the otherhand has three most popular items : ramen, curry and sushi */ 


-- 6. Which item was purchased first by the customer after they became a member?
SELECT DISTINCT members.join_date,
               sales.order_date,
               sales.customer_id,
               sales.order_date,
               menu.product_name as first_item_purchased
FROM dannys_diner.sales
INNER JOIN dannys_diner.members USING(customer_id)
INNER JOIN dannys_diner.menu USING(product_id)
WHERE sales.order_date >= members.join_date
ORDER BY sales.order_date DESC,
         members.join_date
OFFSET 3;

/* Answer:
The first item customer A purchased after becoming a member is curry
while The first item customer B purchased after becoming a member is sushi.*/ 


-- 7. Which item was purchased just before the customer became a member?
SELECT DISTINCT members.join_date,
                 sales.order_date,
                 sales.customer_id,
                menu.product_name as item_purchased
FROM dannys_diner.sales
INNER JOIN dannys_diner.members USING(customer_id)
INNER JOIN dannys_diner.menu USING(product_id)
WHERE sales.order_date < members.join_date
ORDER BY sales.order_date DESC,
         members.join_date
LIMIT 4;

/* Answer:
The item purchased by customer A before becoming a member are curry and sushi 
while the item purchased by customer B before becoming a member is sushi. */ 


-- 8. What is the total items and amount spent for each member before they became a member?
SELECT sales.customer_id AS member,
       COUNT(DISTINCT menu.product_id) AS total_items,
       SUM(menu.price) AS amount_spent
FROM dannys_diner.sales
INNER JOIN dannys_diner.members USING(customer_id)
INNER JOIN dannys_diner.menu USING(product_id)
WHERE sales.order_date < members.join_date
GROUP BY sales.customer_id;

/* Answer:
customer A's total items is 2 and amount spent is 25
while customer B's total items is 2 and amount spent is 40. */ 


-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT sales.customer_id,
       SUM(CASE
               WHEN menu.product_name = 'sushi' THEN menu.price * 20
               WHEN menu.product_name = 'ramen' THEN menu.price * 10
               WHEN menu.product_name = 'curry' THEN menu.price * 10
           END) AS points
FROM dannys_diner.menu
INNER JOIN dannys_diner.sales USING(product_id)
GROUP BY sales.customer_id
ORDER BY sales.customer_id;

/* Answer:
customer A has 860 points
customer B has 940 points
customer C has 360 points. */ 


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
customer A had 1370 points while customer B had 820 points. */
