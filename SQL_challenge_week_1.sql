--1)What is the total amount each customer spent at the restaurant?

SELECT customer_id,SUM(price) as  total_expenditure
FROM sales
LEFT JOIN menu
ON sales.product_id=menu.product_id
GROUP BY customer_id

--2)How many days has each customer visited the restaurant?

SELECT customer_id,COUNT(1) as total_visited_days
FROM
(
SELECT customer_id  , order_date,COUNT(1) as total_product_ordered
FROM sales
GROUP BY customer_id,order_date
)tbl1
GROUP BY tbl1.customer_id

--3) What was the first item from the menu purchased by each customer?

SELECT customer_id,product_name FROM(
SELECT DISTINCT customer_id,rank,product_name FROm (
SELECT customer_id,dense_rank() over(partition by customer_id order by order_date,product_id) as rank,product_id,order_date
FROm sales)tbl1
LEFT JOIN menu
ON tbl1.product_id=menu.product_id
WHERE rank=1
)tbl2

--4)What is the most purchased item on the menu and how many times was it purchased by all customers?


SELECT TOP 1 product_name , COUNT(1) as total_purchased
FROM sales
LEFT JOIN menu ON sales.product_id=menu.product_id
GROUP BY product_name
ORDER BY COUNT(1) desc


--5)Which item was the most popular for each customer?

SELECT customer_id,product_name FROM (
SELECT 
customer_id,product_id,total_purchased, DENSE_RANK()OVER(partition by customer_id order by total_purchased desc) as rank
FROM (
SELECT customer_id,product_id,COUNT(1) as total_purchased
FROm sales
GROUP BY customer_id,product_id
)tbl1
)tbl2
LEFT JOIN menu ON tbl2.product_id=menu.product_id
where rank=1

--6)Which item was purchased first by the customer after they became a member?

SELECT customer_id,product_name FROm (
SELECT 
	m.customer_id,
	m.join_date,
	s.order_date,
	s.product_id,
	menu.product_name,
	DENSE_RANK()over(partition by m.customer_id order by order_date) as rank
FROm members m
LEFT JOIN sales s on m.customer_id=s.customer_id
LEFT JOIN menu  on s.product_id=menu.product_id
where order_date>=join_date
)tbl1
where rank=1

--7)Which item was purchased just before the customer became a member?


SELECT customer_id,product_name FROm (
SELECT 
	m.customer_id,
	m.join_date,
	s.order_date,
	s.product_id,
	menu.product_name,
	DENSE_RANK()over(partition by m.customer_id order by order_date) as rank
FROm members m
LEFT JOIN sales s on m.customer_id=s.customer_id
LEFT JOIN menu  on s.product_id=menu.product_id
where order_date<=join_date
)tbl1
where rank=1

--8) What is the total items and amount spent for each member before they became a member?

SELECT customer_id,count(1) as total_items,SUM(price) as total_price
FROm(
SELECT 
	m.customer_id,
	m.join_date,
	s.order_date,
	s.product_id,
	menu.product_name,
	menu.price,
	DENSE_RANK()over(partition by m.customer_id order by order_date) as rank
FROm members m
LEFT JOIN sales s on m.customer_id=s.customer_id
LEFT JOIN menu  on s.product_id=menu.product_id
where order_date<=join_date
)tbl1
GROUP BY customer_id



--9)If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?


SELECT customer_id,SUM(point) as total_point FROm (
SELECT customer_id, 
	case when product_name='sushi' THEN price*2*10
		 else price*10
		 end as point
	FROM
sales s
LEFT JOIN menu m ON s.product_id=m.product_id
)tbl1
GROUP BY customer_id
--10)In the first week after a customer joins the program (including their join date) they earn 2x points on all items,not just sushi - how many points do customer A and B have at the end of January?

SELECT customer_id,sum(point) as total_points FROm (
SELECT 
	m.customer_id,
	CASE WHEN order_date <= DATEADD(week, 1, join_date) THEN price*2*10
		 when product_name='sushi' THEN price*2*10
		 else price*10
		 end as point

from members m
LEFT JOIN sales s on m.customer_id=s.customer_id
LEFT JOIN menu on s.product_id=menu.product_id
WHERE order_date>=join_date
and order_date<='2021-01-31'
)tbl1
GROUP BY customer_id













