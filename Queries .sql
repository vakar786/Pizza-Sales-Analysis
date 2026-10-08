use pizza;


-- Basic Queries:

-- 1. Retrieve the total number of orders placed.
SELECT 
    COUNT(*) AS total_orders
FROM
    orders;

-- 2. Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(o.quantity * p.price), 2) AS total_revenue
FROM
    pizzas p
        JOIN
    order_details o ON p.pizza_id = o.pizza_id;
    
-- 3. Identify the highest-priced pizza.
SELECT 
    p.name, q.price
FROM
    pizza_types p
        JOIN
    pizzas q ON p.pizza_type_id = q.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- 4. Identify the most common pizza size ordered.
SELECT 
    p.size, SUM(o.quantity) AS total_orders
FROM
    order_details o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY total_orders DESC;

-- 5. List the top 5 most ordered pizza types along with their quantities.
SELECT 
    q.name, SUM(o.quantity) AS total_orders
FROM
    order_details o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id
        JOIN
    pizza_types q ON p.pizza_type_id = q.pizza_type_id
GROUP BY q.name
ORDER BY total_orders DESC
LIMIT 5;


-- Intermediate Queries

-- 1. Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    q.category, SUM(o.quantity) AS total_orders
FROM
    order_details o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id
        JOIN
    pizza_types q ON p.pizza_type_id = q.pizza_type_id
GROUP BY q.category
ORDER BY total_orders DESC;

-- 2. Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hour_of_day, COUNT(order_id)
FROM
    orders
GROUP BY hour_of_day
ORDER BY hour_of_day;

-- 3. Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name) AS total_pizzas
FROM
    pizza_types
GROUP BY category;

-- 4. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(Pizzas_per_Day), 0) AS Average_Pizzas_per_Day
FROM
    (SELECT 
        o.order_date, (SUM(p.quantity)) AS Pizzas_per_Day
    FROM
        orders o
    JOIN order_details p ON o.order_id = p.order_id
    GROUP BY o.order_date
    ORDER BY o.order_date) AS order_quantity;
    
-- 5. Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    q.name, SUM(p.price * o.quantity) AS revenue
FROM
    order_details o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id
        JOIN
    pizza_types q ON p.pizza_type_id = q.pizza_type_id
GROUP BY q.name
ORDER BY revenue DESC
LIMIT 3;


-- Advanced Queries

-- 1. Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    q.category,
    ROUND((SUM(p.price * o.quantity) / (SELECT 
                    ROUND(SUM(p.price * o.quantity), 2)
                FROM
                    order_details o
                        JOIN
                    pizzas p ON o.pizza_id = p.pizza_id
                        JOIN
                    pizza_types q ON p.pizza_type_id = q.pizza_type_id)) * 100,
            2) AS Contribution
FROM
    order_details o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id
        JOIN
    pizza_types q ON p.pizza_type_id = q.pizza_type_id
GROUP BY q.category;

-- 2. Analyze the cumulative revenue generated over time.
SELECT 
	order_date, ROUND(SUM(revenue) OVER (ORDER BY order_date),2) AS cum_revenue 
FROM 
	(SELECT 
		o.order_date, SUM(q.quantity * p.price) AS revenue
	FROM
		order_details q
			JOIN
		orders o ON q.order_id = o.order_id
			JOIN
		pizzas p ON q.pizza_id = p.pizza_id
GROUP BY o.order_date) AS sales;

-- 3. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT 
	category, name, ROUND(revenue,2) , rn 
FROM 
	(SELECT 
		category, name, revenue, rank() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn 
	FROM 
		(SELECT 
			q.category, q.name, SUM(o.quantity * p.price) AS revenue
		FROM
			pizza_types q
				JOIN
			pizzas p ON q.pizza_type_id = p.pizza_type_id
				JOIN
			order_details o ON o.pizza_id = p.pizza_id
		GROUP BY q.category , q.name) AS a) AS b 
WHERE rn<=3;
