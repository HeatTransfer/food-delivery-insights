# create the database
CREATE DATABASE foodsDB;
USE foodsDB;

# create the required tables, define relationships
CREATE TABLE customer ( 
	customer_id INT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    sign_up_date DATE NOT NULL,
    location VARCHAR(255)
);

CREATE TABLE driver (
	driver_id INT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    joined_date DATE NOT NULL,
    vehicle_type VARCHAR(100),
    region VARCHAR(255)
);

CREATE TABLE restaurant (
	restaurant_id INT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    location VARCHAR(255),
    cuisine_type VARCHAR(100),
    signup_date DATE
);

CREATE TABLE orders (
	order_id INT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    driver_id INT,
    order_datetime DATETIME,
    delivery_datetime DATETIME,
    `status` VARCHAR(20) CHECK (status IN ('delivered','cancelled','failed')),
    amount DECIMAL(8,2),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurant(restaurant_id),
    FOREIGN KEY (driver_id) REFERENCES driver(driver_id)
);

CREATE TABLE order_item (
	order_item_id INT PRIMARY KEY,	
    order_id INT,
    item_name VARCHAR(255),
    quantity INT,
    price DECIMAL(6,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
);
    