-- =============================================
-- PostgreSQL 15+ Analytical Queries
-- Vending Machine Sales Performance Analysis
-- Refactored from MySQL with PostgreSQL compatibility
-- Naming convention: lowercase_snake_case
-- =============================================

-- =============================================
-- Query 1: LED Impact Analysis in Low-Light Environments
-- Purpose: Compare sales performance between machines with and without LED lighting
-- in dark areas to quantify the lighting intervention effect
-- =============================================
SELECT 
    CASE WHEN m.has_led_strip = TRUE THEN 'LED Installed' ELSE 'No LED' END AS led_status,
    COUNT(DISTINCT m.machine_id) AS machine_count,
    SUM(s.quantity) AS total_units_sold,
    SUM(s.total_price) AS total_revenue_baht,
    ROUND(AVG(s.quantity)::NUMERIC, 2) AS avg_units_per_transaction
FROM fact_sales s
JOIN dim_vending_machines m ON s.machine_id = m.machine_id
WHERE m.is_low_light = TRUE
GROUP BY m.has_led_strip

UNION ALL

SELECT
    'Total Low-Light Zones' AS led_status,
    COUNT(DISTINCT m.machine_id) AS machine_count,
    SUM(s.quantity) AS total_units_sold,
    SUM(s.total_price) AS total_revenue_baht,
    ROUND(AVG(s.quantity)::NUMERIC, 2) AS avg_units_per_transaction
FROM fact_sales s
JOIN dim_vending_machines m ON s.machine_id = m.machine_id
WHERE m.is_low_light = TRUE;

-- =============================================
-- Query 2: Beverage Category Preference During Night Shift
-- Purpose: Analyze product category popularity patterns during night hours (23:00 - 05:00)
-- to optimize product mix for overnight operations
-- =============================================
SELECT 
    p.category AS beverage_category,
    SUM(s.quantity) AS night_shift_units_sold,
    COUNT(s.transaction_id) AS transaction_count,
    SUM(s.total_price) AS night_shift_revenue_baht,
    ROUND(AVG(s.total_price)::NUMERIC, 2) AS avg_transaction_value_baht
FROM fact_sales s
JOIN dim_products p ON s.product_id = p.product_id
WHERE EXTRACT(HOUR FROM s.sale_timestamp) >= 23 OR EXTRACT(HOUR FROM s.sale_timestamp) < 5
GROUP BY p.category
ORDER BY night_shift_revenue_baht DESC;

-- =============================================
-- Query 3: Sales Performance by Machine Location
-- Purpose: Compare sales effectiveness across different hospital zones
-- to identify high-performing and underperforming locations
-- =============================================
SELECT 
    m.machine_id,
    m.location_zone,
    CASE WHEN m.is_low_light = TRUE THEN 'Dark' ELSE 'Well-lit' END AS lighting_condition,
    CASE WHEN m.has_led_strip = TRUE THEN 'Yes' ELSE 'No' END AS led_installed,
    COUNT(DISTINCT s.transaction_id) AS transaction_count,
    SUM(s.quantity) AS total_units_sold,
    SUM(s.total_price) AS total_revenue_baht,
    ROUND(AVG(s.total_price)::NUMERIC, 2) AS avg_revenue_per_transaction_baht
FROM fact_sales s
JOIN dim_vending_machines m ON s.machine_id = m.machine_id
GROUP BY m.machine_id, m.location_zone, m.is_low_light, m.has_led_strip
ORDER BY total_revenue_baht DESC;

-- =============================================
-- Query 4: Product Performance Metrics
-- Purpose: Identify best-selling products by volume and revenue
-- to guide inventory allocation and promotional strategies
-- =============================================
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.menu_type AS service_type,
    SUM(s.quantity) AS total_units_sold,
    COUNT(DISTINCT s.transaction_id) AS transaction_count,
    SUM(s.total_price) AS total_revenue_baht,
    ROUND((SUM(s.total_price) / SUM(s.quantity))::NUMERIC, 2) AS avg_price_per_unit_baht
FROM fact_sales s
JOIN dim_products p ON s.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category, p.menu_type
ORDER BY total_revenue_baht DESC;

-- =============================================
-- Query 5: Topping Adoption Analysis
-- Purpose: Measure uptake rates of optional toppings
-- to understand customer preferences for premium add-ons
-- =============================================
SELECT 
    t.topping_id,
    t.topping_name,
    COUNT(s.transaction_id) AS selection_count,
    SUM(s.quantity) AS total_units_with_topping,
    SUM(s.topping_price * s.quantity) AS topping_revenue_baht,
    ROUND((COUNT(s.transaction_id)::NUMERIC / (SELECT COUNT(*) FROM fact_sales) * 100), 2) AS selection_rate_percent
FROM fact_sales s
JOIN dim_toppings t ON s.topping_id = t.topping_id
GROUP BY t.topping_id, t.topping_name
ORDER BY selection_count DESC;

-- =============================================
-- Query 6: Hourly Sales Distribution Pattern
-- Purpose: Identify peak and off-peak sales periods
-- to support staffing and inventory planning decisions
-- =============================================
SELECT 
    EXTRACT(HOUR FROM s.sale_timestamp)::INT AS hour_of_day,
    COUNT(s.transaction_id) AS transaction_count,
    SUM(s.quantity) AS units_sold,
    SUM(s.total_price) AS hourly_revenue_baht,
    CASE 
        WHEN EXTRACT(HOUR FROM s.sale_timestamp) >= 23 OR EXTRACT(HOUR FROM s.sale_timestamp) < 5 THEN 'Night Shift (23:00-05:00)'
        WHEN EXTRACT(HOUR FROM s.sale_timestamp) >= 5 AND EXTRACT(HOUR FROM s.sale_timestamp) < 12 THEN 'Morning (05:00-12:00)'
        WHEN EXTRACT(HOUR FROM s.sale_timestamp) >= 12 AND EXTRACT(HOUR FROM s.sale_timestamp) < 17 THEN 'Afternoon (12:00-17:00)'
        ELSE 'Evening (17:00-23:00)'
    END AS time_period
FROM fact_sales s
GROUP BY EXTRACT(HOUR FROM s.sale_timestamp)
ORDER BY hour_of_day;

-- =============================================
-- Query 7: Executive Summary Statistics
-- Purpose: High-level overview of all sales metrics
-- for dashboard and reporting purposes
-- =============================================
SELECT 
    COUNT(DISTINCT s.transaction_id) AS total_transactions,
    COUNT(DISTINCT s.machine_id) AS active_machines,
    COUNT(DISTINCT s.product_id) AS product_varieties,
    SUM(s.quantity) AS total_units_sold,
    SUM(s.total_price) AS total_revenue_baht,
    ROUND(AVG(s.total_price)::NUMERIC, 2) AS avg_transaction_value_baht,
    ROUND((SUM(s.total_price) / COUNT(DISTINCT s.machine_id))::NUMERIC, 2) AS avg_revenue_per_machine_baht,
    MIN(s.sale_timestamp) AS earliest_transaction_date,
    MAX(s.sale_timestamp) AS latest_transaction_date
FROM fact_sales s;

-- =============================================
-- Query 8: LED Impact by Location (Cross-dimensional Analysis)
-- Purpose: Evaluate LED lighting effectiveness
-- within specific hospital zones
-- =============================================
SELECT 
    m.location_zone,
    CASE WHEN m.has_led_strip = TRUE THEN 'LED Installed' ELSE 'No LED' END AS led_status,
    COUNT(DISTINCT m.machine_id) AS machine_count,
    SUM(s.quantity) AS units_sold,
    SUM(s.total_price) AS location_revenue_baht,
    ROUND((SUM(s.total_price) / COUNT(DISTINCT m.machine_id))::NUMERIC, 2) AS avg_revenue_per_machine_baht
FROM fact_sales s
JOIN dim_vending_machines m ON s.machine_id = m.machine_id
GROUP BY m.location_zone, m.has_led_strip
ORDER BY m.location_zone, m.has_led_strip;

-- =============================================
-- Query 9: Transaction Status Analysis
-- Purpose: Monitor data quality and transaction success rates
-- to identify operational issues requiring attention
-- =============================================
SELECT 
    s.status AS transaction_status,
    COUNT(s.transaction_id) AS status_count,
    SUM(s.quantity) AS units_with_status,
    SUM(s.total_price) AS revenue_by_status_baht,
    ROUND((COUNT(s.transaction_id)::NUMERIC / (SELECT COUNT(*) FROM fact_sales) * 100), 2) AS percentage_of_total
FROM fact_sales s
GROUP BY s.status;

-- =============================================
-- Query 10: Detailed Machine and Product Cross-Analysis
-- Purpose: Examine product sales patterns within each machine
-- to identify location-specific product preferences
-- =============================================
SELECT 
    m.machine_id,
    m.location_zone,
    p.product_name,
    SUM(s.quantity) AS units_sold,
    SUM(s.total_price) AS product_revenue_baht,
    COUNT(s.transaction_id) AS sales_transaction_count
FROM fact_sales s
JOIN dim_vending_machines m ON s.machine_id = m.machine_id
JOIN dim_products p ON s.product_id = p.product_id
GROUP BY m.machine_id, m.location_zone, p.product_name
ORDER BY m.machine_id, product_revenue_baht DESC;
