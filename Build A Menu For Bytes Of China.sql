-- ============================================
-- TASK GROUP 1: CREATE TABLES AND PRIMARY KEYS
-- ============================================

-- Task 1 & 2: Create restaurant and address tables
CREATE TABLE restaurant (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    telephone TEXT,
    hours TEXT,
    rating REAL,
    review_count INTEGER,
    website TEXT,
    email TEXT
);

CREATE TABLE address (
    id INTEGER PRIMARY KEY,
    street_number TEXT,
    street_name TEXT,
    city TEXT,
    state TEXT,
    zip_code TEXT,
    restaurant_id INTEGER UNIQUE,
    FOREIGN KEY (restaurant_id) REFERENCES restaurant(id)
);

-- Validate primary keys for restaurant and address
SELECT name FROM pragma_table_info('restaurant') WHERE pk > 0;
SELECT name FROM pragma_table_info('address') WHERE pk > 0;

-- Task 3: Create category table
CREATE TABLE category (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT
);

-- Validate primary key for category
SELECT name FROM pragma_table_info('category') WHERE pk > 0;

-- Task 4: Create dish table
CREATE TABLE dish (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price DECIMAL(5,2),
    spicy BOOLEAN DEFAULT 0
);

-- Validate primary key for dish
SELECT name FROM pragma_table_info('dish') WHERE pk > 0;

-- Task 5: Create review table
CREATE TABLE review (
    id INTEGER PRIMARY KEY,
    rating DECIMAL(3,1),
    description TEXT,
    date DATE,
    restaurant_id INTEGER,
    FOREIGN KEY (restaurant_id) REFERENCES restaurant(id)
);

-- Validate primary key for review
SELECT name FROM pragma_table_info('review') WHERE pk > 0;

-- ============================================
-- TASK GROUP 2: DEFINE RELATIONSHIPS AND FOREIGN KEYS
-- ============================================

-- Task 6: One-to-One relationship (restaurant and address)
-- Already implemented with UNIQUE constraint on address.restaurant_id

-- Validate foreign key on address
SELECT "foreign key exists" FROM pragma_foreign_key_list('address') 
WHERE "table" = 'restaurant' AND "from" = 'restaurant_id';

-- Task 7: One-to-Many relationship (restaurant and review)
-- Already implemented with foreign key on review.restaurant_id

-- Validate foreign key on review
SELECT "foreign key exists" FROM pragma_foreign_key_list('review') 
WHERE "table" = 'restaurant' AND "from" = 'restaurant_id';

-- Task 8: Many-to-Many relationship (category and dish)
-- Create cross-reference table
CREATE TABLE categories_dishes (
    category_id TEXT,
    dish_id INTEGER,
    price DECIMAL(5,2),
    PRIMARY KEY (category_id, dish_id),
    FOREIGN KEY (category_id) REFERENCES category(id),
    FOREIGN KEY (dish_id) REFERENCES dish(id)
);

-- Validate primary and foreign keys for categories_dishes
SELECT name FROM pragma_table_info('categories_dishes') WHERE pk > 0;
SELECT "foreign key exists" FROM pragma_foreign_key_list('categories_dishes') 
WHERE "table" IN ('category', 'dish');

-- ============================================
-- TASK GROUP 3: INSERT SAMPLE DATA
-- ============================================

-- Insert restaurant data
INSERT INTO restaurant (id, name, telephone, hours, rating, review_count, website, email)
VALUES (1, 'Bytes of China', '617-555-1212', 'Mon - Fri 9:00 am to 9:00 pm, Weekends 10:00 am to 11:00 pm', 3.9, 200, 'www.byteofchina.com', 'info@byteofchina.com');

-- Insert address data
INSERT INTO address (id, street_number, street_name, city, state, zip_code, restaurant_id)
VALUES (1, '2020', 'Busy Street', 'Chinatown', 'MA', '02139', 1);

-- Insert categories
INSERT INTO category (id, name, description) VALUES
    ('A', 'Appetizers', NULL),
    ('S', 'Soup', NULL),
    ('C', 'Chicken', NULL),
    ('B', 'Beef', NULL),
    ('V', 'Veal', NULL),
    ('VG', 'Vegetarian', NULL),
    ('RN', 'Rice and Noodles', NULL),
    ('LS', 'Luncheon Specials', 'Served with Hot and Sour Soup or Egg Drop Soup and Fried or Steamed Rice between 11:00 am and 3:00 pm from Monday to Friday.'),
    ('HS', 'House Specials', NULL);

-- Insert dishes
INSERT INTO dish (id, name, description, price, spicy) VALUES
    (1, 'Spring Rolls', 'Vegetable spring rolls served with sweet chili sauce', 4.95, 0),
    (2, 'Wonton Soup', 'Pork wontons in clear broth', 3.95, 0),
    (3, 'Kung Pao Chicken', 'Diced chicken with peanuts and vegetables in spicy sauce', 12.95, 1),
    (4, 'Mongolian Beef', 'Sliced beef with scallions in savory sauce', 13.95, 0),
    (5, 'Veal with Broccoli', 'Tender veal with fresh broccoli in brown sauce', 14.95, 0),
    (6, 'Mapo Tofu', 'Tofu in spicy bean-based sauce', 10.95, 1),
    (7, 'Fried Rice', 'Egg fried rice with peas and carrots', 7.95, 0),
    (8, 'House Special Lo Mein', 'Noodles with shrimp, chicken, and beef', 11.95, 0),
    (9, 'Chicken with Broccoli', 'Chicken breast with fresh broccoli in brown sauce', 11.95, 0),
    (10, 'Szechuan Chicken', 'Spicy chicken with vegetables in Szechuan sauce', 12.95, 1),
    (11, 'Beef with Broccoli', 'Tender beef with fresh broccoli in brown sauce', 12.95, 0);

-- Insert category-dish relationships
INSERT INTO categories_dishes (category_id, dish_id, price) VALUES
    ('A', 1, 4.95),
    ('S', 2, 3.95),
    ('C', 3, 12.95),
    ('C', 9, 11.95),
    ('C', 10, 12.95),
    ('B', 4, 13.95),
    ('B', 11, 12.95),
    ('V', 5, 14.95),
    ('VG', 6, 10.95),
    ('RN', 7, 7.95),
    ('RN', 8, 11.95),
    ('LS', 9, 8.95),
    ('HS', 9, 11.95),
    ('HS', 3, 12.95),
    ('HS', 4, 13.95),
    ('HS', 5, 14.95);

-- Insert reviews
INSERT INTO review (id, rating, description, date, restaurant_id) VALUES
    (1, 5.0, 'Awesome service. Would love to host another birthday party at Bytes of China!', '2020-05-22', 1),
    (2, 4.5, 'Other than a small mix-up, I would give it a 5.0!', '2020-04-01', 1),
    (3, 3.9, 'A reasonable place to eat for lunch, if you are in a rush!', '2020-03-15', 1);

-- ============================================
-- TASK GROUP 4: MAKE SAMPLE QUERIES
-- ============================================

-- Task 10: Display restaurant name, address, and telephone
SELECT 
    r.name AS restaurant_name,
    a.street_number || ' ' || a.street_name AS address,
    r.telephone
FROM restaurant r
JOIN address a ON r.id = a.restaurant_id;

-- Task 11: Get the best rating
SELECT MAX(rating) AS best_rating
FROM review;

-- Task 12: Display dish name, price, and category sorted by dish name
SELECT 
    d.name AS dish_name,
    cd.price,
    c.name AS category
FROM dish d
JOIN categories_dishes cd ON d.id = cd.dish_id
JOIN category c ON cd.category_id = c.id
ORDER BY d.name;

-- Task 13: Display category, dish name, and price sorted by category name
SELECT 
    c.name AS category,
    d.name AS dish_name,
    cd.price
FROM category c
JOIN categories_dishes cd ON c.id = cd.category_id
JOIN dish d ON cd.dish_id = d.id
ORDER BY c.name;

-- Task 14: Display all spicy dishes
SELECT 
    d.name AS spicy_dish_name,
    c.name AS category,
    cd.price
FROM dish d
JOIN categories_dishes cd ON d.id = cd.dish_id
JOIN category c ON cd.category_id = c.id
WHERE d.spicy = 1
ORDER BY d.name;

-- Task 15: Display dish_id and count for categories_dishes
SELECT 
    dish_id,
    COUNT(dish_id) AS dish_count
FROM categories_dishes
GROUP BY dish_id;

-- Task 16: Display dishes that appear more than once
SELECT 
    dish_id,
    COUNT(dish_id) AS dish_count
FROM categories_dishes
GROUP BY dish_id
HAVING dish_count > 1;

-- Task 17: Display dish names that appear more than once
SELECT 
    d.name AS dish_name,
    COUNT(cd.dish_id) AS dish_count
FROM dish d
JOIN categories_dishes cd ON d.id = cd.dish_id
GROUP BY d.id, d.name
HAVING dish_count > 1;

-- Task 18: Display best rating with description using subquery
SELECT 
    rating AS best_rating,
    description
FROM review
WHERE rating = (SELECT MAX(rating) FROM review);