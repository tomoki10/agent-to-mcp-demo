-- Initial database setup for GitHub Copilot MySQL MCP Demo (Enhanced)

CREATE DATABASE IF NOT EXISTS demo_db;
USE demo_db;

-- ============================================
-- Users table
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
-- Categories table (hierarchical)
-- ============================================
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    parent_id INT DEFAULT NULL,
    FOREIGN KEY (parent_id) REFERENCES categories(id)
);

-- ============================================
-- Products table
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
-- Coupons table
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
-- Orders table
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
-- Order items table
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
-- Shipping table
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
-- Reviews table
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
-- Sample data
-- ============================================

-- Users (5 records)
INSERT INTO users (name, email, age, department) VALUES
('Taro Tanaka', 'tanaka@example.com', 28, 'Development'),
('Hanako Sato', 'sato@example.com', 32, 'Marketing'),
('Ichiro Suzuki', 'suzuki@example.com', 25, 'Sales'),
('Misaki Takahashi', 'takahashi@example.com', 29, 'Design'),
('Kenta Yamada', 'yamada@example.com', 35, 'Development');

-- Categories (parent 1 + child 5, 2-level hierarchy)
INSERT INTO categories (id, name, parent_id) VALUES
(1, 'Electronics', NULL),
(2, 'Laptops', 1),
(3, 'Peripherals', 1),
(4, 'Monitors', 1),
(5, 'Smartphones & Tablets', 1),
(6, 'Audio', 1);

-- Products (8 records)
INSERT INTO products (name, price, stock, category_id, description) VALUES
('MacBook Pro', 199800.00, 10, 2, 'Latest MacBook Pro with M3 chip'),
('Wireless Mouse', 2980.00, 50, 3, 'High-precision wireless mouse'),
('Mechanical Keyboard', 12800.00, 25, 3, 'Mechanical keyboard with great tactile feel'),
('4K Monitor', 35900.00, 15, 4, '27-inch 4K resolution monitor'),
('Web Camera', 8900.00, 30, 3, 'Full HD web camera'),
('Smartphone', 89800.00, 20, 5, 'Latest flagship smartphone model'),
('Tablet', 45600.00, 18, 5, '10-inch tablet'),
('Headphones', 15400.00, 40, 6, 'Noise-canceling headphones');

-- Coupons (4 records: 2 percentage, 2 fixed, 1 expired)
INSERT INTO coupons (code, discount_type, discount_value, min_order_amount, valid_from, valid_until, usage_limit, times_used) VALUES
('SPRING10', 'percentage', 10.00, 5000.00, '2026-01-01', '2026-06-30', 100, 2),
('WELCOME20', 'percentage', 20.00, 10000.00, '2026-01-01', '2026-12-31', 50, 1),
('SAVE3000', 'fixed', 3000.00, 20000.00, '2026-02-01', '2026-04-30', 30, 1),
('SUMMER500', 'fixed', 500.00, 3000.00, '2025-06-01', '2025-08-31', 200, 15);

-- Orders (12 records: all statuses covered, dates from 2025/10 to 2026/3)
-- Order 1: Taro Tanaka - MacBook Pro + Mouse (no coupon)
INSERT INTO orders (id, user_id, coupon_id, subtotal, discount_amount, total_price, order_date, status) VALUES
(1, 1, NULL, 202780.00, 0, 202780.00, '2025-10-15', 'delivered');
-- Order 2: Hanako Sato - Keyboard + Web Camera (SPRING10 applied)
INSERT INTO orders (id, user_id, coupon_id, subtotal, discount_amount, total_price, order_date, status) VALUES
(2, 2, 1, 21700.00, 2170.00, 19530.00, '2025-11-03', 'delivered');
-- Order 3: Ichiro Suzuki - Smartphone (WELCOME20 applied)
INSERT INTO orders (id, user_id, coupon_id, subtotal, discount_amount, total_price, order_date, status) VALUES
(3, 3, 2, 89800.00, 17960.00, 71840.00, '2025-11-20', 'delivered');
-- Order 4: Misaki Takahashi - 4K Monitor (no coupon)
INSERT INTO orders (id, user_id, coupon_id, subtotal, discount_amount, total_price, order_date, status) VALUES
(4, 4, NULL, 35900.00, 0, 35900.00, '2025-12-01', 'delivered');
-- Order 5: Kenta Yamada - MacBook Pro + 4K Monitor + Keyboard (SAVE3000 applied)
INSERT INTO orders (id, user_id, coupon_id, subtotal, discount_amount, total_price, order_date, status) VALUES
(5, 5, 3, 248500.00, 3000.00, 245500.00, '2025-12-10', 'delivered');
-- Order 6: Taro Tanaka - Headphones (no coupon)
INSERT INTO orders (id, user_id, coupon_id, subtotal, discount_amount, total_price, order_date, status) VALUES
(6, 1, NULL, 15400.00, 0, 15400.00, '2026-01-08', 'shipped');
-- Order 7: Hanako Sato - Tablet (no coupon)
INSERT INTO orders (id, user_id, coupon_id, subtotal, discount_amount, total_price, order_date, status) VALUES
(7, 2, NULL, 45600.00, 0, 45600.00, '2026-01-22', 'shipped');
-- Order 8: Ichiro Suzuki - Mouse + Keyboard (no coupon)
INSERT INTO orders (id, user_id, coupon_id, subtotal, discount_amount, total_price, order_date, status) VALUES
(8, 3, NULL, 15780.00, 0, 15780.00, '2026-02-05', 'confirmed');
-- Order 9: Misaki Takahashi - Headphones + Web Camera (no coupon)
INSERT INTO orders (id, user_id, coupon_id, subtotal, discount_amount, total_price, order_date, status) VALUES
(9, 4, NULL, 24300.00, 0, 24300.00, '2026-02-14', 'confirmed');
-- Order 10: Kenta Yamada - Smartphone (no coupon)
INSERT INTO orders (id, user_id, coupon_id, subtotal, discount_amount, total_price, order_date, status) VALUES
(10, 5, NULL, 89800.00, 0, 89800.00, '2026-03-01', 'pending');
-- Order 11: Taro Tanaka - Tablet + Headphones (no coupon)
INSERT INTO orders (id, user_id, coupon_id, subtotal, discount_amount, total_price, order_date, status) VALUES
(11, 1, NULL, 61000.00, 0, 61000.00, '2026-03-15', 'pending');
-- Order 12: Hanako Sato - Smartphone (cancelled)
INSERT INTO orders (id, user_id, coupon_id, subtotal, discount_amount, total_price, order_date, status) VALUES
(12, 2, NULL, 89800.00, 0, 89800.00, '2026-03-20', 'cancelled');

-- Order items (product breakdown for each order)
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
-- Order 1: MacBook Pro + Mouse
(1, 1, 1, 199800.00),
(1, 2, 1, 2980.00),
-- Order 2: Keyboard + Web Camera
(2, 3, 1, 12800.00),
(2, 5, 1, 8900.00),
-- Order 3: Smartphone
(3, 6, 1, 89800.00),
-- Order 4: 4K Monitor
(4, 4, 1, 35900.00),
-- Order 5: MacBook Pro + 4K Monitor + Keyboard
(5, 1, 1, 199800.00),
(5, 4, 1, 35900.00),
(5, 3, 1, 12800.00),
-- Order 6: Headphones
(6, 8, 1, 15400.00),
-- Order 7: Tablet
(7, 7, 1, 45600.00),
-- Order 8: Mouse + Keyboard
(8, 2, 1, 2980.00),
(8, 3, 1, 12800.00),
-- Order 9: Headphones + Web Camera
(9, 8, 1, 15400.00),
(9, 5, 1, 8900.00),
-- Order 10: Smartphone
(10, 6, 1, 89800.00),
-- Order 11: Tablet + Headphones
(11, 7, 1, 45600.00),
(11, 8, 1, 15400.00),
-- Order 12: Smartphone (cancelled)
(12, 6, 1, 89800.00);

-- Shipping (10 records: 5 delivered, 3 shipped, 2 not yet shipped)
INSERT INTO shipping (order_id, address, city, postal_code, carrier, shipped_date, delivered_date) VALUES
(1, '1-2-3 Jinnan, Shibuya-ku, Tokyo', 'Tokyo', '150-0041', 'Yamato Transport', '2025-10-16', '2025-10-18'),
(2, '4-5-6 Umeda, Kita-ku, Osaka', 'Osaka', '530-0001', 'Sagawa Express', '2025-11-04', '2025-11-08'),
(3, '7-8-9 Sakae, Naka-ku, Nagoya', 'Nagoya', '460-0008', 'Yamato Transport', '2025-11-21', '2025-11-23'),
(4, '10-11 Hakata-ekimae, Hakata-ku, Fukuoka', 'Fukuoka', '812-0011', 'Japan Post', '2025-12-02', '2025-12-06'),
(5, '12-13 Odori, Chuo-ku, Sapporo', 'Sapporo', '060-0042', 'Yamato Transport', '2025-12-11', '2025-12-14'),
(6, '1-2-3 Jinnan, Shibuya-ku, Tokyo', 'Tokyo', '150-0041', 'Sagawa Express', '2026-01-09', NULL),
(7, '4-5-6 Umeda, Kita-ku, Osaka', 'Osaka', '530-0001', 'Yamato Transport', '2026-01-23', NULL),
(8, '7-8-9 Sakae, Naka-ku, Nagoya', 'Nagoya', '460-0008', 'Sagawa Express', '2026-02-06', NULL),
(9, '10-11 Hakata-ekimae, Hakata-ku, Fukuoka', 'Fukuoka', '812-0011', NULL, NULL, NULL),
(10, '12-13 Odori, Chuo-ku, Sapporo', 'Sapporo', '060-0042', NULL, NULL, NULL);

-- Reviews (15 records: ratings 1-5 distributed, at least 1 per product)
INSERT INTO reviews (user_id, product_id, rating, comment, created_at) VALUES
(1, 1, 5, 'The M3 chip performance is amazing. Development work is so much smoother.', '2025-10-25 10:00:00'),
(5, 1, 4, 'Expensive but worth it. Battery life is also great.', '2025-12-20 14:30:00'),
(2, 2, 4, 'Fits well in the hand and easy to use. Great value.', '2025-11-10 09:00:00'),
(3, 3, 5, 'The typing feel is amazing! Programming is fun now.', '2026-02-15 11:00:00'),
(5, 3, 4, 'Comfortable typing sound. A bit heavy though.', '2025-12-25 16:00:00'),
(4, 4, 3, 'Good image quality, but the stand adjustment range is a bit narrow.', '2025-12-10 13:00:00'),
(1, 4, 5, 'Wide workspace with 4K resolution. Perfect for dual monitors.', '2026-01-15 10:30:00'),
(4, 5, 3, 'Average image quality. Would have been nice to have auto brightness.', '2025-12-05 15:00:00'),
(3, 6, 5, 'Outstanding camera performance. The best smartphone for daily use.', '2025-12-01 12:00:00'),
(5, 6, 2, 'Battery life below expectations. Questionable at this price point.', '2026-03-05 17:00:00'),
(2, 7, 4, 'Light and portable. Perfect for watching videos.', '2026-02-01 08:00:00'),
(1, 7, 4, 'Great size for reading and browsing.', '2026-03-20 09:30:00'),
(1, 8, 5, 'The noise canceling effect is incredible. Helps me focus.', '2026-01-20 11:00:00'),
(4, 8, 4, 'Great sound quality and comfortable for long listening sessions.', '2026-02-20 14:00:00'),
(2, 5, 2, 'Narrow viewing angle, not ideal for meetings. Fine for personal use.', '2025-11-15 16:30:00');

-- ============================================
-- Views
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
    COALESCE(c.code, 'None') as coupon_code
FROM orders o
JOIN users u ON o.user_id = u.id
JOIN order_items oi ON o.id = oi.order_id
LEFT JOIN coupons c ON o.coupon_id = c.id
GROUP BY o.id, u.name, o.order_date, o.status, o.subtotal, o.discount_amount, o.total_price, c.code;

-- Data verification
SELECT 'Tables:' as info;
SHOW TABLES;
