-- =============================================
-- PostgreSQL 15+ Optimization and Strategic Recommendations
-- Refactored from MySQL with PostgreSQL compatibility
-- Naming convention: lowercase_snake_case
-- =============================================

-- =============================================
-- Query 1: Restock Recommendation Engine
-- =============================================
-- Purpose: Calculate sales velocity and forecast days until stockout
-- to optimize inventory replenishment timing and quantities
WITH sales_velocity AS (
    SELECT 
        s.product_id,
        SUM(s.quantity) AS total_sold,
        COUNT(DISTINCT DATE(s.sale_timestamp)) AS active_sales_days,
        -- Calculate average daily demand based on historical sales
        SUM(s.quantity) / NULLIF(COUNT(DISTINCT DATE(s.sale_timestamp)), 0) AS avg_daily_demand
    FROM fact_sales s
    WHERE s.status = 'completed'
    GROUP BY s.product_id
),
current_inventory AS (
    -- Baseline assumption: 50 units per product type per machine
    -- In production, integrate with actual inventory management system
    SELECT 
        product_id,
        50 AS current_stock_units
    FROM dim_products
)
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    sv.total_sold,
    ROUND(sv.avg_daily_demand::NUMERIC, 2) AS avg_daily_demand_units,
    ci.current_stock_units,
    
    -- Forecast days until stockout at current demand rate
    ROUND((ci.current_stock_units / NULLIF(sv.avg_daily_demand, 0))::NUMERIC, 2) AS days_until_stockout,

    -- Alert priority system for inventory management dashboard
    CASE 
        WHEN ci.current_stock_units / NULLIF(sv.avg_daily_demand, 0) < 2 THEN '🔴 URGENT RESTOCK'
        WHEN ci.current_stock_units / NULLIF(sv.avg_daily_demand, 0) < 5 THEN '🟡 RESTOCK SOON'
        ELSE '🟢 STOCK OK'
    END AS restock_alert_priority
FROM sales_velocity sv
JOIN current_inventory ci ON sv.product_id = ci.product_id
JOIN dim_products p ON p.product_id = sv.product_id;

-- =============================================
-- Query 2: Product Profitability & Popularity Analysis
-- =============================================
-- Purpose: Calculate revenue and popularity scores for strategic product ranking
-- and margin optimization decisions
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price AS unit_price_baht,

    SUM(s.quantity) AS total_units_sold,
    -- Calculate revenue based on base product price
    SUM(s.quantity * p.price) AS total_product_revenue_baht,

    -- Popularity metric: count of distinct purchase transactions
    COUNT(DISTINCT s.transaction_id) AS popularity_transaction_count,

    -- Strategic optimization score for product ranking
    ROUND((SUM(s.quantity) * p.price)::NUMERIC, 2) AS strategic_optimization_score

FROM fact_sales s
JOIN dim_products p ON s.product_id = p.product_id
WHERE s.status = 'completed'
GROUP BY p.product_id, p.product_name, p.category, p.price
ORDER BY strategic_optimization_score DESC;

-- =============================================
-- Query 3: Machine Performance and Optimization Strategy
-- =============================================
-- Purpose: Evaluate vending machine effectiveness based on location,
-- lighting conditions, and LED installation to guide operational improvements
SELECT 
    m.machine_id,
    m.location_zone,
    m.is_low_light,
    m.has_led_strip,

    SUM(s.quantity) AS total_sales_units,
    -- Calculate revenue contribution by machine
    SUM(s.quantity * p.price) AS total_machine_revenue_baht,

    -- Strategic business recommendations based on performance and configuration
    CASE 
        -- Priority 1: Dark locations without LED require immediate lighting upgrade
        WHEN m.is_low_light = TRUE AND m.has_led_strip = FALSE THEN '💡 INSTALL LED IMMEDIATELY'
        -- Priority 2: Low-performing machines need product mix review
        WHEN SUM(s.quantity) < 5 THEN '⚠️ LOW PERFORMER - REVIEW PRODUCT MIX'
        -- Priority 3: High-revenue machines warrant capacity expansion
        WHEN SUM(s.quantity * p.price) > 300 THEN '🚀 HIGH PERFORMER - SCALE STOCK CAPACITY'
        -- Default: Normal operational status
        ELSE '✅ NORMAL PERFORMANCE'
    END AS strategic_recommendation

FROM fact_sales s
JOIN dim_vending_machines m ON s.machine_id = m.machine_id
JOIN dim_products p ON s.product_id = p.product_id
GROUP BY m.machine_id, m.location_zone, m.is_low_light, m.has_led_strip;

-- =============================================
-- Query 4: Inventory Allocation Optimization (ABC Analysis)
-- =============================================
-- Purpose: Recommend product allocation ratios for machine shelf space
-- based on demand patterns and profitability analysis
SELECT 
    p.product_id,
    p.product_name,
    SUM(s.quantity) AS total_demand_units,

    -- Space allocation recommendation for vending machine shelving
    -- based on historical demand velocity
    CASE 
        WHEN SUM(s.quantity) >= 5 THEN 'HIGH ALLOCATION (80% Shelf Space)'
        WHEN SUM(s.quantity) >= 2 THEN 'MEDIUM ALLOCATION (50% Shelf Space)'
        ELSE 'LOW ALLOCATION (20% Shelf Space)'
    END AS recommended_shelf_allocation
FROM fact_sales s
JOIN dim_products p ON p.product_id = s.product_id
WHERE s.status = 'completed'
GROUP BY p.product_id, p.product_name
ORDER BY total_demand_units DESC;
