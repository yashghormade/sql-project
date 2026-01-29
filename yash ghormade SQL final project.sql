                    # YASH GHORMADE 
                    # SQL FINAL PROJECT 

SHOW DATABASES;

CREATE DATABASE IF NOT EXISTS projectDB;

USE projectDB;

SHOW TABLES;
SELECT * FROM customers;
SELECT * FROM order_items;
SELECT * FROM orders;
SELECT * FROM payments;
SELECT * FROM products;

# Q-1) Find customers who have placed more than 3 orders.
SELECT customer_id, COUNT(*) AS total_orders
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 3;

#Q-2) Display the top 5 customers based on total purchase value.
SELECT o.customer_id, SUM(oi.quantity * p.price) AS total_spent
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.customer_id
ORDER BY total_spent DESC
LIMIT 5;



# Q-3) List products that have never been ordered
SELECT p.product_id, p.product_name
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;


# Q-4) Find the most sold product (by quantity).
SELECT product_id, SUM(quantity) AS total_qty
FROM order_items
GROUP BY product_id
ORDER BY total_qty DESC
LIMIT 1;


# Q-5) Show each customer’s latest order using a single query.
SELECT *
FROM orders o
WHERE order_date = (
  SELECT MAX(order_date)
  FROM orders
  WHERE customer_id = o.customer_id
);
ALTER TABLE orders
ADD COLUMN status VARCHAR(20);

UPDATE orders SET status = 'Delivered' WHERE order_id = 1;
UPDATE orders SET status = 'Pending' WHERE order_id = 2;
UPDATE orders SET status = 'Delivered' WHERE order_id = 3;
SELECT * FROM orders;

# Q-6) Identify orders where payment failed but order status is marked as Delivered.
SELECT o.order_id
FROM orders o
JOIN payments p ON o.order_id = p.order_id
WHERE p.payment_status = 'Failed'
AND o.status = 'Delivered';


# Q-7) Calculate total revenue generated per product category
SELECT p.category, SUM(oi.quantity * p.price) AS revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category;


# Q-8) Find customers who placed orders but never made a successful payment.
SELECT DISTINCT o.customer_id
FROM orders o
JOIN payments p ON o.order_id = p.order_id
WHERE p.payment_status != 'Success';

# Q-9) Display each order along with the total bill amount after discount.
ALTER TABLE orders
ADD COLUMN discount DECIMAL(10,2) DEFAULT 0;

UPDATE orders SET discount = 500 WHERE order_id = 1;
UPDATE orders SET discount = 0 WHERE order_id = 2;
UPDATE orders SET discount = 200 WHERE order_id = 3;

SELECT o.order_id,
       SUM(oi.quantity * p.price) - o.discount AS final_amount
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.order_id, o.discount;



# Q-10) Rank customers within each city based on total spending.
SELECT c.customer_id, c.city,
       SUM(oi.quantity * p.price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.customer_id, c.city
ORDER BY c.city, total_spent DESC;


# Q-11) Find the second highest priced product in each category.
SELECT *
FROM products p1
WHERE 1 = (
  SELECT COUNT(DISTINCT price)
  FROM products p2
  WHERE p2.category = p1.category
  AND p2.price > p1.price
);

# Q-12)Show month-wise total number of orders and revenue.
SELECT MONTH(o.order_date) AS month,
       COUNT(DISTINCT o.order_id) AS total_orders,
       SUM(oi.quantity * p.price) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY MONTH(o.order_date);


# Q-13) Identify customers whose total spending is above the average customer spending.
SELECT o.customer_id, SUM(oi.quantity * p.price) AS total_spent
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.customer_id
HAVING SUM(oi.quantity * p.price) >
(
    SELECT AVG(sub.total_spent)
    FROM (
        SELECT SUM(oi2.quantity * p2.price) AS total_spent
        FROM orders o2
        JOIN order_items oi2 ON o2.order_id = oi2.order_id
        JOIN products p2 ON oi2.product_id = p2.product_id
        GROUP BY o2.customer_id
    ) AS sub
);


# Q-14) Display orders where order total is greater than any order placed by customers from Delhi.
SELECT o.order_id, SUM(oi.quantity * p.price) AS total_amount
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.order_id
HAVING SUM(oi.quantity * p.price) >
(
    SELECT MAX(sub.total_amount)
    FROM (
        SELECT o2.order_id, SUM(oi2.quantity * p2.price) AS total_amount
        FROM orders o2
        JOIN order_items oi2 ON o2.order_id = oi2.order_id
        JOIN products p2 ON oi2.product_id = p2.product_id
        JOIN customers c2 ON o2.customer_id = c2.customer_id
        WHERE c2.city = 'Delhi'
        GROUP BY o2.order_id
    ) AS sub
);


# Q-15) Write a query to show cumulative revenue ordered by order date.
SELECT o.order_date,
       SUM(oi.quantity * p.price) AS daily_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.order_date
ORDER BY o.order_date;


# Q-16) Find products whose stock is less than the average stock of their category.
SELECT *
FROM products p
WHERE stock <
(

# Q-17) Create a stored procedure to fetch all orders of a given customer.
DELIMITER $$

DROP PROCEDURE IF EXISTS getOrders;

DELIMITER $$

CREATE PROCEDURE getOrders(IN cust_id INT)
BEGIN
    SELECT *
    FROM orders
    WHERE customer_id = cust_id;
END $$

DELIMITER ;



# Q-18) Identify customers who placed an order on the same day they signed up.
SELECT DISTINCT c.customer_id
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE DATE(c.signup_date) = DATE(o.order_date);

