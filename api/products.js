// GET /api/products  -> 回傳 clothing 資料表（含分類、品牌名稱）
const mysql = require("mysql2/promise");

module.exports = async (req, res) => {
  res.setHeader("Access-Control-Allow-Origin", "*"); // 只讀的公開商品資料
  res.setHeader("Cache-Control", "s-maxage=60");
  if (req.method === "OPTIONS") return res.status(204).end();

  let conn;
  try {
    const ca = (process.env.DB_CA || "").replace(/\\n/g, "\n");
    conn = await mysql.createConnection({
      host: process.env.DB_HOST,
      port: Number(process.env.DB_PORT),
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME || "clothing_store",
      ssl: { ca },
      dateStrings: true,
      connectTimeout: 10000,
    });
    const [rows] = await conn.query(
      `SELECT c.product_id, c.product_name, g.category_name AS category, b.brand_name AS brand,
              c.color, c.size, c.price, c.stock_qty, c.listed_date, c.image_url, c.image_match
       FROM clothing c
       JOIN categories g ON c.category_id = g.category_id
       JOIN brands b ON c.brand_id = b.brand_id
       ORDER BY c.product_id`
    );
    res.status(200).json(rows.map((r) => ({ ...r, price: Number(r.price) })));
  } catch (e) {
    res.status(500).json({ error: "db_error", message: e.code || e.message });
  } finally {
    if (conn) await conn.end();
  }
};
