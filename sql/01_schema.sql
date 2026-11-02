-- 服飾資料庫 clothing_store (MySQL 8 / TiDB Cloud 通用)
CREATE DATABASE IF NOT EXISTS clothing_store DEFAULT CHARACTER SET utf8mb4;
USE clothing_store;
SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS stock_reservation, order_items, orders, customers, clothing, product_images, brands, categories;
SET FOREIGN_KEY_CHECKS=1;
CREATE TABLE categories(category_id INT PRIMARY KEY, category_name VARCHAR(30) NOT NULL);
CREATE TABLE brands(brand_id INT PRIMARY KEY, brand_name VARCHAR(50) NOT NULL, country VARCHAR(20));
CREATE TABLE product_images(           -- 圖片管理表：一張照片一列
  image_id INT PRIMARY KEY, file_name VARCHAR(60) NOT NULL UNIQUE,
  image_url VARCHAR(255) NOT NULL, photo_type VARCHAR(20) NOT NULL);
CREATE TABLE clothing(
  product_id VARCHAR(10) PRIMARY KEY, product_name VARCHAR(60) NOT NULL,
  category_id INT NOT NULL, brand_id INT NOT NULL, color VARCHAR(20), size VARCHAR(10),
  price DECIMAL(10,2) NOT NULL, stock_qty INT NOT NULL, listed_date DATE,
  image_id INT NULL, image_url VARCHAR(255) NULL, image_match VARCHAR(12) NULL,
  FOREIGN KEY(category_id) REFERENCES categories(category_id),
  FOREIGN KEY(brand_id) REFERENCES brands(brand_id),
  FOREIGN KEY(image_id) REFERENCES product_images(image_id));
CREATE TABLE customers(customer_id VARCHAR(10) PRIMARY KEY, customer_name VARCHAR(30) NOT NULL, city VARCHAR(20), member_level VARCHAR(10));
CREATE TABLE orders(order_id VARCHAR(10) PRIMARY KEY, customer_id VARCHAR(10) NOT NULL, order_date DATE NOT NULL, status VARCHAR(10) NOT NULL,
  FOREIGN KEY(customer_id) REFERENCES customers(customer_id));
CREATE TABLE order_items(item_id VARCHAR(10) PRIMARY KEY, order_id VARCHAR(10) NOT NULL, product_id VARCHAR(10) NOT NULL, quantity INT NOT NULL, unit_price DECIMAL(10,2) NOT NULL,
  FOREIGN KEY(order_id) REFERENCES orders(order_id), FOREIGN KEY(product_id) REFERENCES clothing(product_id));
