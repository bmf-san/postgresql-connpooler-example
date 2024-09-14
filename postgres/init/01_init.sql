CREATE DATABASE example;

\c example

-- Enable pg_stat_statements extension
CREATE EXTENSION pg_stat_statements;

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    category_id INT,
    price NUMERIC(10, 2),
    stock INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255)
);

INSERT INTO categories (name)
VALUES
('Electronics'),
('Books'),
('Clothing'),
('Toys'),
('Furniture');

INSERT INTO products (name, category_id, price, stock)
SELECT
    md5(random()::text),
    (random() * 4 + 1)::int,
    trunc(random() * 1000)::numeric(10, 2),
    (random() * 100)::int
FROM generate_series(1, 1000000);
