create database Pizza;

use Pizza;

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL
);

CREATE TABLE order_details (
    order_detail_id INT PRIMARY KEY,
    order_id INT REFERENCES orders (order_id),
    pizza_id VARCHAR(50) REFERENCES pizza_types (pizza_type_id),
    quantity INT NOT NULL
);