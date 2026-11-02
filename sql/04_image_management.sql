USE clothing_store;
-- 圖片管理架構：product_images(照片清單+類型) <- clothing.image_id / image_url
-- 驗證 1：每件商品都有圖，且 60 張互不重複
SELECT COUNT(*) AS products, COUNT(DISTINCT image_id) AS distinct_images FROM clothing;
-- 驗證 2：各分類的圖片相符程度 (exact=款式相符 / similar=相近 / placeholder=暫代，待補拍)
SELECT g.category_name, c.image_match, COUNT(*) AS n FROM clothing c JOIN categories g USING(category_id) GROUP BY g.category_name, c.image_match ORDER BY 1,2;
-- 待補照片清單
SELECT product_id, product_name, color, p.photo_type AS current_photo_type FROM clothing c JOIN product_images p USING(image_id) WHERE image_match='placeholder';
