USE clothing_store;
-- A1
SELECT c.product_name, c.price FROM clothing c JOIN categories g ON c.category_id=g.category_id WHERE g.category_name='上衣' ORDER BY c.price DESC;
-- A2
SELECT c.product_id, c.product_name, c.price FROM clothing c JOIN brands b ON c.brand_id=b.brand_id WHERE b.brand_name='Urban Leaf' AND c.price>1000;
-- A3
SELECT DISTINCT cu.customer_name FROM customers cu JOIN orders o ON o.customer_id=cu.customer_id JOIN order_items i ON i.order_id=o.order_id WHERE o.status='已完成' ORDER BY cu.customer_name;
-- A4 (集合差集：2025 有售、2026 沒售)
SELECT i.product_id FROM order_items i JOIN orders o ON o.order_id=i.order_id WHERE o.status='已完成' AND o.order_date>='2025-01-01' AND o.order_date<'2026-01-01'
EXCEPT
SELECT i.product_id FROM order_items i JOIN orders o ON o.order_id=i.order_id WHERE o.status='已完成' AND o.order_date>='2026-01-01' AND o.order_date<'2027-01-01';
-- A5
SELECT c.product_name, b.brand_name, c.price FROM clothing c JOIN brands b ON c.brand_id=b.brand_id WHERE c.product_name LIKE '%外套%';
-- B1
SELECT g.category_name, COUNT(*) AS product_count, AVG(c.price) AS avg_price FROM clothing c JOIN categories g ON c.category_id=g.category_id GROUP BY g.category_id, g.category_name HAVING COUNT(*)>2;
-- B2
SELECT product_name, price FROM clothing WHERE price=(SELECT MAX(price) FROM clothing);
-- B3
SELECT c.product_id, c.product_name, COALESCE(SUM(CASE WHEN o.status='已完成' THEN i.quantity END),0) AS total_qty
FROM clothing c LEFT JOIN order_items i ON i.product_id=c.product_id LEFT JOIN orders o ON o.order_id=i.order_id GROUP BY c.product_id, c.product_name ORDER BY c.product_id;
-- C1 建表 (需 MySQL 8.0.16+ 才會強制 CHECK；TiDB 請先確認版本)
CREATE TABLE stock_reservation(
  reservation_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id VARCHAR(10) NOT NULL, product_id VARCHAR(10) NOT NULL, reserve_date DATE NOT NULL,
  quantity INT NOT NULL, CONSTRAINT chk_qty CHECK (quantity BETWEEN 1 AND 4),
  CONSTRAINT uq_res UNIQUE (customer_id, product_id, reserve_date),
  CONSTRAINT fk_res_cus FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
  CONSTRAINT fk_res_pro FOREIGN KEY (product_id) REFERENCES clothing(product_id) ON DELETE CASCADE);
INSERT INTO stock_reservation(customer_id,product_id,reserve_date,quantity) VALUES('C001','P0001','2026-03-01',2),('C002','P0002','2026-03-02',1);
-- 以下三筆應失敗，請各別執行並截圖錯誤訊息
INSERT INTO stock_reservation(customer_id,product_id,reserve_date,quantity) VALUES('C001','P0001','2026-03-01',1); -- 違反 UNIQUE
INSERT INTO stock_reservation(customer_id,product_id,reserve_date,quantity) VALUES('C003','P0003','2026-03-03',6); -- 違反 CHECK(1~4)
INSERT INTO stock_reservation(customer_id,product_id,reserve_date,quantity) VALUES('C001','P9999','2026-03-04',1); -- 違反 FOREIGN KEY
-- C2 (MySQL / MariaDB 版；TiDB 不支援 CREATE FUNCTION)
DELIMITER //
CREATE FUNCTION total_sales(p_brand_id INT) RETURNS DECIMAL(12,2) READS SQL DATA
BEGIN
  DECLARE t DECIMAL(12,2);
  SELECT COALESCE(SUM(i.quantity*i.unit_price),0) INTO t FROM order_items i JOIN orders o ON o.order_id=i.order_id JOIN clothing c ON c.product_id=i.product_id
  WHERE c.brand_id=p_brand_id AND o.status='已完成';
  RETURN t;
END//
DELIMITER ;
SELECT brand_id, brand_name, total_sales(brand_id) AS sales FROM brands WHERE total_sales(brand_id)>10000;
-- C2 (TiDB 替代：以 VIEW/查詢取代函數，品牌參數改為 WHERE brand_id=?)
SELECT b.brand_id, b.brand_name, SUM(i.quantity*i.unit_price) AS sales FROM brands b JOIN clothing c ON c.brand_id=b.brand_id
JOIN order_items i ON i.product_id=c.product_id JOIN orders o ON o.order_id=i.order_id WHERE o.status='已完成' GROUP BY b.brand_id, b.brand_name HAVING SUM(i.quantity*i.unit_price)>10000;
