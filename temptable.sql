USE sakila;

-- Step 1: Create the rental summary view
CREATE VIEW rental_summary AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email AS customer_email,
    COUNT(r.rental_id) AS rental_count
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id;

-- Step 2: Create the temporary table for total payments
CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT 
    c.customer_id,
    SUM(p.amount) AS total_paid
FROM rental_summary c
JOIN rental r ON c.customer_id = r.customer_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.customer_id;

-- Step 3: Create the CTE for the customer summary report
WITH customer_summary AS (
    SELECT 
        rs.customer_name,
        rs.customer_email,
        rs.rental_count,
        cps.total_paid,
        (cps.total_paid / rs.rental_count) AS average_payment_per_rental
    FROM rental_summary rs
    JOIN customer_payment_summary cps ON rs.customer_id = cps.customer_id
)
-- Final query to generate the customer summary report
SELECT 
    customer_name,
    customer_email,
    rental_count,
    total_paid,
    average_payment_per_rental
FROM customer_summary;

-- Clean up (optional) - Drop temporary table after use
DROP TEMPORARY TABLE IF EXISTS customer_payment_summary;

-- Optional - Drop view after use (if no longer needed)
DROP VIEW IF EXISTS rental_summary;
