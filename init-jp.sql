-- GitHub Copilot MySQL MCP Demo 用の初期データベース設定（拡張版）

CREATE DATABASE IF NOT EXISTS demo_db;
USE demo_db;

-- ============================================
-- ユーザーテーブル
-- ============================================
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    age INT,
    department VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- カテゴリテーブル（階層構造）
-- ============================================
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    parent_id INT DEFAULT NULL,
    FOREIGN KEY (parent_id) REFERENCES categories(id)
);

-- ============================================
-- 商品テーブル
-- ============================================
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

-- ============================================
-- クーポンテーブル
-- ============================================
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

-- ============================================
-- 注文テーブル
-- ============================================
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

-- ============================================
-- 注文明細テーブル
-- ============================================
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- ============================================
-- 配送テーブル
-- ============================================
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

-- ============================================
-- レビューテーブル
-- ============================================
CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    rating TINYINT NOT NULL,
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- ============================================
-- サンプルデータ投入
-- ============================================

-- ユーザー（5件）
INSERT INTO users (name, email, age, department) VALUES
('田中太郎', 'tanaka@example.com', 28, '開発部'),
('佐藤花子', 'sato@example.com', 32, 'マーケティング部'),
('鈴木一郎', 'suzuki@example.com', 25, '営業部'),
('高橋美咲', 'takahashi@example.com', 29, 'デザイン部'),
('山田健太', 'yamada@example.com', 35, '開発部');

-- カテゴリ（親1＋子5の2階層）
INSERT INTO categories (id, name, parent_id) VALUES
(1, '電子機器', NULL),
(2, 'ノートPC', 1),
(3, '周辺機器', 1),
(4, 'モニター', 1),
(5, 'スマートフォン・タブレット', 1),
(6, 'オーディオ', 1);

-- 商品（8件）
INSERT INTO products (name, price, stock, category_id, description) VALUES
('MacBook Pro', 199800.00, 10, 2, '最新のM3チップ搭載のノートパソコン'),
('ワイヤレスマウス', 2980.00, 50, 3, '高精度なワイヤレスマウス'),
('メカニカルキーボード', 12800.00, 25, 3, '打鍵感の良いメカニカルキーボード'),
('4Kモニター', 35900.00, 15, 4, '27インチ4K解像度モニター'),
('Webカメラ', 8900.00, 30, 3, 'フルHD対応Webカメラ'),
('スマートフォン', 89800.00, 20, 5, '最新のフラッグシップモデル'),
('タブレット', 45600.00, 18, 5, '10インチタブレット'),
('ヘッドフォン', 15400.00, 40, 6, 'ノイズキャンセリング機能付き');

-- クーポン（4件：percentage 2件、fixed 2件、うち1件は期限切れ）
INSERT INTO coupons (code, discount_type, discount_value, min_order_amount, valid_from, valid_until, usage_limit, times_used) VALUES
('SPRING10', 'percentage', 10.00, 5000.00, '2026-01-01', '2026-06-30', 100, 2),
('WELCOME20', 'percentage', 20.00, 10000.00, '2026-01-01', '2026-12-31', 50, 1),
('SAVE3000', 'fixed', 3000.00, 20000.00, '2026-02-01', '2026-04-30', 30, 1),
('SUMMER500', 'fixed', 500.00, 3000.00, '2025-06-01', '2025-08-31', 200, 15);

-- 注文（12件：全ステータス網羅、2025/10～2026/3に分散）
-- 注文1: 田中太郎 - MacBook Pro + マウス（クーポンなし）
INSERT INTO orders (id, user_id, coupon_id, subtotal, discount_amount, total_price, order_date, status) VALUES
(1, 1, NULL, 202780.00, 0, 202780.00, '2025-10-15', 'delivered');
-- 注文2: 佐藤花子 - キーボード + Webカメラ（SPRING10 適用）
INSERT INTO orders (id, user_id, coupon_id, subtotal, discount_amount, total_price, order_date, status) VALUES
(2, 2, 1, 21700.00, 2170.00, 19530.00, '2025-11-03', 'delivered');
-- 注文3: 鈴木一郎 - スマートフォン（WELCOME20 適用）
INSERT INTO orders (id, user_id, coupon_id, subtotal, discount_amount, total_price, order_date, status) VALUES
(3, 3, 2, 89800.00, 17960.00, 71840.00, '2025-11-20', 'delivered');
-- 注文4: 高橋美咲 - 4Kモニター（クーポンなし）
INSERT INTO orders (id, user_id, coupon_id, subtotal, discount_amount, total_price, order_date, status) VALUES
(4, 4, NULL, 35900.00, 0, 35900.00, '2025-12-01', 'delivered');
-- 注文5: 山田健太 - MacBook Pro + 4Kモニター + キーボード（SAVE3000 適用）
INSERT INTO orders (id, user_id, coupon_id, subtotal, discount_amount, total_price, order_date, status) VALUES
(5, 5, 3, 248500.00, 3000.00, 245500.00, '2025-12-10', 'delivered');
-- 注文6: 田中太郎 - ヘッドフォン（クーポンなし）
INSERT INTO orders (id, user_id, coupon_id, subtotal, discount_amount, total_price, order_date, status) VALUES
(6, 1, NULL, 15400.00, 0, 15400.00, '2026-01-08', 'shipped');
-- 注文7: 佐藤花子 - タブレット（クーポンなし）
INSERT INTO orders (id, user_id, coupon_id, subtotal, discount_amount, total_price, order_date, status) VALUES
(7, 2, NULL, 45600.00, 0, 45600.00, '2026-01-22', 'shipped');
-- 注文8: 鈴木一郎 - マウス + キーボード（クーポンなし）
INSERT INTO orders (id, user_id, coupon_id, subtotal, discount_amount, total_price, order_date, status) VALUES
(8, 3, NULL, 15780.00, 0, 15780.00, '2026-02-05', 'confirmed');
-- 注文9: 高橋美咲 - ヘッドフォン + Webカメラ（クーポンなし）
INSERT INTO orders (id, user_id, coupon_id, subtotal, discount_amount, total_price, order_date, status) VALUES
(9, 4, NULL, 24300.00, 0, 24300.00, '2026-02-14', 'confirmed');
-- 注文10: 山田健太 - スマートフォン（クーポンなし）
INSERT INTO orders (id, user_id, coupon_id, subtotal, discount_amount, total_price, order_date, status) VALUES
(10, 5, NULL, 89800.00, 0, 89800.00, '2026-03-01', 'pending');
-- 注文11: 田中太郎 - タブレット + ヘッドフォン（クーポンなし）
INSERT INTO orders (id, user_id, coupon_id, subtotal, discount_amount, total_price, order_date, status) VALUES
(11, 1, NULL, 61000.00, 0, 61000.00, '2026-03-15', 'pending');
-- 注文12: 佐藤花子 - スマートフォン（キャンセル済み）
INSERT INTO orders (id, user_id, coupon_id, subtotal, discount_amount, total_price, order_date, status) VALUES
(12, 2, NULL, 89800.00, 0, 89800.00, '2026-03-20', 'cancelled');

-- 注文明細（各注文の商品内訳）
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
-- 注文1: MacBook Pro + マウス
(1, 1, 1, 199800.00),
(1, 2, 1, 2980.00),
-- 注文2: キーボード + Webカメラ
(2, 3, 1, 12800.00),
(2, 5, 1, 8900.00),
-- 注文3: スマートフォン
(3, 6, 1, 89800.00),
-- 注文4: 4Kモニター
(4, 4, 1, 35900.00),
-- 注文5: MacBook Pro + 4Kモニター + キーボード
(5, 1, 1, 199800.00),
(5, 4, 1, 35900.00),
(5, 3, 1, 12800.00),
-- 注文6: ヘッドフォン
(6, 8, 1, 15400.00),
-- 注文7: タブレット
(7, 7, 1, 45600.00),
-- 注文8: マウス + キーボード
(8, 2, 1, 2980.00),
(8, 3, 1, 12800.00),
-- 注文9: ヘッドフォン + Webカメラ
(9, 8, 1, 15400.00),
(9, 5, 1, 8900.00),
-- 注文10: スマートフォン
(10, 6, 1, 89800.00),
-- 注文11: タブレット + ヘッドフォン
(11, 7, 1, 45600.00),
(11, 8, 1, 15400.00),
-- 注文12: スマートフォン（キャンセル）
(12, 6, 1, 89800.00);

-- 配送情報（10件：delivered 5件、shipped 3件、未発送 2件）
INSERT INTO shipping (order_id, address, city, postal_code, carrier, shipped_date, delivered_date) VALUES
(1, '東京都渋谷区神南1-2-3', '東京', '150-0041', 'ヤマト運輸', '2025-10-16', '2025-10-18'),
(2, '大阪府大阪市北区梅田4-5-6', '大阪', '530-0001', '佐川急便', '2025-11-04', '2025-11-08'),
(3, '愛知県名古屋市中区栄7-8-9', '名古屋', '460-0008', 'ヤマト運輸', '2025-11-21', '2025-11-23'),
(4, '福岡県福岡市博多区博多駅前10-11', '福岡', '812-0011', '日本郵便', '2025-12-02', '2025-12-06'),
(5, '北海道札幌市中央区大通12-13', '札幌', '060-0042', 'ヤマト運輸', '2025-12-11', '2025-12-14'),
(6, '東京都渋谷区神南1-2-3', '東京', '150-0041', '佐川急便', '2026-01-09', NULL),
(7, '大阪府大阪市北区梅田4-5-6', '大阪', '530-0001', 'ヤマト運輸', '2026-01-23', NULL),
(8, '愛知県名古屋市中区栄7-8-9', '名古屋', '460-0008', '佐川急便', '2026-02-06', NULL),
(9, '福岡県福岡市博多区博多駅前10-11', '福岡', '812-0011', NULL, NULL, NULL),
(10, '北海道札幌市中央区大通12-13', '札幌', '060-0042', NULL, NULL, NULL);

-- レビュー（15件：全商品に最低1件、星1〜5を分散）
INSERT INTO reviews (user_id, product_id, rating, comment, created_at) VALUES
(1, 1, 5, 'M3チップの性能が素晴らしい。開発作業が快適になりました。', '2025-10-25 10:00:00'),
(5, 1, 4, '高価ですがその価値はあります。バッテリー持ちも良好。', '2025-12-20 14:30:00'),
(2, 2, 4, '手にフィットして使いやすい。コスパも良い。', '2025-11-10 09:00:00'),
(3, 3, 5, '打鍵感が最高！プログラミングが楽しくなります。', '2026-02-15 11:00:00'),
(5, 3, 4, 'タイピング音が心地よい。少し重いのが難点。', '2025-12-25 16:00:00'),
(4, 4, 3, '画質は良いが、スタンドの調整範囲がやや狭い。', '2025-12-10 13:00:00'),
(1, 4, 5, '4K解像度で作業領域が広い。デュアルモニターに最適。', '2026-01-15 10:30:00'),
(4, 5, 3, '画質は普通。明るさの自動調整があると良かった。', '2025-12-05 15:00:00'),
(3, 6, 5, 'カメラ性能が抜群。普段使いには最高のスマートフォン。', '2025-12-01 12:00:00'),
(5, 6, 2, 'バッテリーの持ちが期待以下。価格を考えると微妙。', '2026-03-05 17:00:00'),
(2, 7, 4, '軽くて持ち運びやすい。動画視聴に最適。', '2026-02-01 08:00:00'),
(1, 7, 4, '読書やブラウジングにちょうど良いサイズ。', '2026-03-20 09:30:00'),
(1, 8, 5, 'ノイズキャンセリングの効果がすごい。集中できる。', '2026-01-20 11:00:00'),
(4, 8, 4, '音質が良く長時間つけても疲れない。', '2026-02-20 14:00:00'),
(2, 5, 2, '画角が狭くて会議には不向き。個人利用なら問題なし。', '2025-11-15 16:30:00');

-- ============================================
-- ビューの作成
-- ============================================
CREATE VIEW order_summary AS
SELECT
    o.id as order_id,
    u.name as customer_name,
    o.order_date,
    o.status,
    o.subtotal,
    o.discount_amount,
    o.total_price,
    COUNT(oi.id) as item_count,
    COALESCE(c.code, 'なし') as coupon_code
FROM orders o
JOIN users u ON o.user_id = u.id
JOIN order_items oi ON o.id = oi.order_id
LEFT JOIN coupons c ON o.coupon_id = c.id
GROUP BY o.id, u.name, o.order_date, o.status, o.subtotal, o.discount_amount, o.total_price, c.code;

-- データの確認
SELECT 'テーブル一覧:' as info;
SHOW TABLES;
