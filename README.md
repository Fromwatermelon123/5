# clothing-search 服飾資料庫作業

| 資料夾 | 內容 |
|---|---|
| `sql/01_schema.sql` | 建立 clothing_store、6 張表 + product_images、PK/FK |
| `sql/02_data.sql` | 匯入全部資料（含 image_url） |
| `sql/03_homework_queries.sql` | A1–C2 作業題目 |
| `sql/04_image_management.sql` | 圖片管理驗證查詢 |
| `colab/clothing_db.ipynb` | Colab 連線 TiDB Cloud 測試 |
| `docs/` | Dashboard（GitHub Pages：Settings → Pages → Branch main /docs） |

## 圖片管理架構
`product_images`（圖庫，記錄每張照片類型）→ `clothing.image_id`（FK）＋ `clothing.image_url`。
`image_match`：exact＝款式相符、similar＝相近、placeholder＝暫代（待補拍）。

## 注意
- TiDB 不支援 CREATE FUNCTION，C2 另附 TiDB 替代查詢。
- 連線密碼請勿上傳 GitHub。
