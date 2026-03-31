# Text-to-SQL デモ拡張計画

## 概要

現在の3テーブル構成を8テーブルに拡張し、多段JOIN・サブクエリ・CASE式などの複雑なSQLもText-to-SQLで生成できることをデモする。

## 背景

現在のスキーマ（`users`, `products`, `orders` + 1ビュー）では、最大でも2テーブルのJOINしか発生せず、Text-to-SQLの実力を示すには不十分である。ECサイトシナリオを自然に拡張し、実務的にリアリティのある構造でデモの説得力を高める。

## 拡張方針

### 追加テーブル（5テーブル）

| テーブル | 役割 | デモ可能になるSQL機能 |
|---|---|---|
| `categories` | 商品カテゴリマスタ（階層構造） | 自己JOIN |
| `order_items` | 注文明細（1注文に複数商品） | 多段JOIN、集約関数 |
| `reviews` | 商品レビュー（星評価+コメント） | AVG/COUNT、サブクエリ |
| `coupons` | クーポン（割引率/額/有効期限） | CASE式、日付関数 |
| `shipping` | 配送情報（配送先/配送日/業者） | DATEDIFF、IS NULL |

### 既存テーブルの変更

- **products**: `category`文字列を`category_id` FKに正規化
- **orders**: `product_id`/`quantity`を削除し`order_items`に分離。`coupon_id`, `subtotal`, `discount_amount`を追加
- **users**: 変更なし

## ER図

```text
categories ←(自己参照: parent_id)
  └─ 1:N ─→ products
                ├─ 1:N ─→ order_items ←─ N:1 ─ orders ←─ N:1 ─ users
                └─ 1:N ─→ reviews     ←─ N:1 ──────────────────── users
                                          orders ─ 1:1 ─→ shipping
                                          orders ←─ N:1 ─ coupons
```

## テーブル定義

### categories（新規）

```sql
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    parent_id INT DEFAULT NULL,
    FOREIGN KEY (parent_id) REFERENCES categories(id)
);
```

### products（変更）

```sql
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    category_id INT,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);
```

### coupons（新規）

```sql
CREATE TABLE coupons (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    discount_type ENUM('percentage', 'fixed') NOT NULL,
    discount_value DECIMAL(10,2) NOT NULL,
    min_order_amount DECIMAL(10,2) DEFAULT 0,
    valid_from DATE NOT NULL,
    valid_until DATE NOT NULL,
    usage_limit INT DEFAULT NULL,
    times_used INT DEFAULT 0
);
```

### orders（変更）

```sql
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    coupon_id INT DEFAULT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    total_price DECIMAL(10,2) NOT NULL,
    order_date DATE NOT NULL,
    status ENUM('pending', 'confirmed', 'shipped', 'delivered', 'cancelled')
        DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (coupon_id) REFERENCES coupons(id)
);
```

### order_items（新規）

```sql
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);
```

### shipping（新規）

```sql
CREATE TABLE shipping (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT UNIQUE NOT NULL,
    address VARCHAR(200) NOT NULL,
    city VARCHAR(50) NOT NULL,
    postal_code VARCHAR(10) NOT NULL,
    carrier VARCHAR(50),
    shipped_date DATE DEFAULT NULL,
    delivered_date DATE DEFAULT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id)
);
```

### reviews（新規）

```sql
CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);
```

## サンプルデータ方針

| テーブル | 件数 | ポイント |
|---|---|---|
| users | 5件 | 既存維持 |
| categories | 6件 | 親カテゴリ1件＋子カテゴリ5件の2階層 |
| products | 8件 | `category_id`への差し替えのみ |
| coupons | 4件 | percentage 2件、fixed 2件。期限切れ1件を含む |
| orders | 12件 | 全ステータス網羅。2025/10～2026/3に日付分散。クーポン適用2件 |
| order_items | 20件程度 | 1注文あたり1～3商品。金額の整合性を確保 |
| shipping | 10件 | delivered 5件、shipped(未着) 3件、未発送 2件 |
| reviews | 15件 | 星1～5を分散。全商品に最低1件 |

### データ設計上の注意点

- `order_date`を複数月にまたがらせる（月別集計デモ用）
- クーポンの`valid_until`に過去日を含める（日付比較デモ用）
- shippingの`shipped_date`/`delivered_date`にNULLを含める（IS NULL条件デモ用）
- reviewsのratingを意図的に偏らせる（高評価/低評価商品のパターン）
- `order_items`の合計金額と`orders.subtotal`の整合性を保つ

## デモ用自然言語クエリ例

### Level 1: 基本（単一テーブル）

**Q1. 「全ユーザーの一覧を見せてください」**

```sql
SELECT * FROM users;
```

**Q2. 「在庫が20個以下の商品を価格の高い順に教えてください」**

```sql
SELECT name, price, stock FROM products
WHERE stock <= 20 ORDER BY price DESC;
```

### Level 2: JOIN（2テーブル）

**Q3. 「各商品の平均レビュー評価を教えてください」**

```sql
SELECT p.name, AVG(r.rating) as avg_rating, COUNT(r.id) as review_count
FROM products p
LEFT JOIN reviews r ON p.id = r.product_id
GROUP BY p.id, p.name;
```

**Q4. 「現在有効なクーポンの一覧を表示してください」**

```sql
SELECT code, discount_type, discount_value, valid_until
FROM coupons
WHERE valid_from <= CURDATE() AND valid_until >= CURDATE();
```

### Level 3: 多段JOIN（3テーブル以上）

**Q5. 「田中太郎さんが購入した商品の一覧と各商品の金額を表示してください」**

```sql
SELECT p.name, oi.quantity, oi.unit_price,
       (oi.quantity * oi.unit_price) as item_total
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
JOIN users u ON o.user_id = u.id
WHERE u.name = '田中太郎';
```

**Q6. 「カテゴリ別の売上合計を教えてください」**

```sql
SELECT c.name as category,
       SUM(oi.quantity * oi.unit_price) as total_sales
FROM categories c
JOIN products p ON c.id = p.category_id
JOIN order_items oi ON p.id = oi.product_id
GROUP BY c.id, c.name
ORDER BY total_sales DESC;
```

### Level 4: CASE式/サブクエリ

**Q7. 「各注文の割引内容を表示してください（パーセント割引ならXX%OFF、固定額ならXXXX円引き、クーポンなしなら割引なし）」**

```sql
SELECT o.id, o.total_price,
  CASE
    WHEN c.discount_type = 'percentage' THEN CONCAT(c.discount_value, '%OFF')
    WHEN c.discount_type = 'fixed' THEN CONCAT(c.discount_value, '円引き')
    ELSE '割引なし'
  END as discount_info
FROM orders o
LEFT JOIN coupons c ON o.coupon_id = c.id;
```

**Q8. 「平均注文金額より高い注文をしたユーザーを教えてください」**

```sql
SELECT DISTINCT u.name, o.total_price
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE o.total_price > (SELECT AVG(total_price) FROM orders);
```

### Level 5: 複合的/高度

**Q9. 「月別の売上推移と、各月の注文件数、平均注文単価を教えてください」**

```sql
SELECT
  DATE_FORMAT(o.order_date, '%Y-%m') as month,
  COUNT(DISTINCT o.id) as order_count,
  SUM(o.total_price) as monthly_sales,
  AVG(o.total_price) as avg_order_value
FROM orders o
WHERE o.status != 'cancelled'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY month;
```

**Q10. 「レビュー評価が4以上の商品だけを買っているユーザーで、合計購入額が5万円以上の人を教えてください」**

```sql
SELECT u.name, SUM(o.total_price) as total_spent
FROM users u
JOIN orders o ON u.id = o.user_id
JOIN order_items oi ON o.id = oi.order_id
WHERE oi.product_id IN (
    SELECT product_id FROM reviews
    GROUP BY product_id HAVING AVG(rating) >= 4
)
GROUP BY u.id, u.name
HAVING total_spent >= 50000;
```

**Q11. 「配送に3日以上かかった注文について、ユーザー名、商品名、配送業者、所要日数を教えてください」**

```sql
SELECT u.name, p.name as product, s.carrier,
  DATEDIFF(s.delivered_date, s.shipped_date) as delivery_days
FROM shipping s
JOIN orders o ON s.order_id = o.id
JOIN users u ON o.user_id = u.id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
WHERE s.delivered_date IS NOT NULL
  AND DATEDIFF(s.delivered_date, s.shipped_date) >= 3;
```

## SQL機能カバレッジ

| SQL機能 | カバーするクエリ例 |
|---|---|
| 多段JOIN | Q5, Q6, Q10, Q11 |
| 集約関数 + GROUP BY | Q3, Q6, Q9, Q10 |
| サブクエリ | Q8, Q10 |
| CASE式 | Q7 |
| 複合条件WHERE | Q4, Q11 |
| 日付関数 | Q4, Q9, Q11 |

## 実装ステップ

### Step 1: init-jp.sqlの書き換え

テーブル定義を8テーブル構成に全面書き換えし、サンプルデータを投入する。`order_summary`ビューも新構造に合わせて更新する。

### Step 2: init.sqlの書き換え

`init-jp.sql`と同構造で英語データ版を作成する。

### Step 3: 動作確認

```bash
docker compose down -v
docker compose up -d
```

MCPサーバー経由で`SHOW TABLES`を実行し、8テーブルが作成されていることを確認する。

### Step 4: README.mdの更新

テーブル構造の説明とクエリ例を更新する。

## 対象ファイル

| ファイル | 変更内容 |
|---|---|
| `init-jp.sql` | 全面書き換え |
| `init.sql` | 全面書き換え |
| `README.md` | テーブル構造とクエリ例の更新 |
| `docker-compose.yml` | 変更なし（確認のみ） |

## 検証方法

1. `docker compose down -v && docker compose up -d`でコンテナを再構築する
2. `SHOW TABLES`で8テーブルの存在を確認する
3. デモクエリ例を自然言語で投げ、正しいSQLが生成されるか確認する
4. 特に多段JOIN（Q5, Q11）とサブクエリ（Q8, Q10）の精度を重点的に確認する
