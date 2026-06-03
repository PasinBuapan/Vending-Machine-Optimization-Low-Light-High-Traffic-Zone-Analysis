-- =============================================
-- 1. Restock Recommendation Engine
-- =============================================
WITH sales_velocity AS (
    SELECT 
        s.product_id,
        SUM(s.quantity) AS total_sold,
        COUNT(DISTINCT DATE(s.sale_timestamp)) AS active_days,
        SUM(s.quantity) / NULLIF(COUNT(DISTINCT DATE(s.sale_timestamp)), 0) AS avg_daily_demand
    FROM Fact_Sales s
    WHERE s.status = 'completed'
    GROUP BY s.product_id
),
current_inventory AS (
    -- สมมติ inventory baseline (mock logic)
    SELECT 
        product_id,
        50 AS current_stock
    FROM Dim_Products
)

SELECT 
    p.product_id,
    p.product_name,
    sv.total_sold,
    sv.avg_daily_demand,
    ci.current_stock,
    
    -- Days until stockout
    ROUND(ci.current_stock / NULLIF(sv.avg_daily_demand, 0), 2) AS days_to_stockout,

    CASE 
        WHEN ci.current_stock / NULLIF(sv.avg_daily_demand, 0) < 2 
            THEN 'URGENT RESTOCK'
        WHEN ci.current_stock / NULLIF(sv.avg_daily_demand, 0) < 5 
            THEN 'RESTOCK SOON'
        ELSE 'OK'
    END AS restock_priority

FROM sales_velocity sv
JOIN current_inventory ci ON sv.product_id = ci.product_id
JOIN Dim_Products p ON p.product_id = sv.product_id;
-- =============================================
-- 2. Product Profitability Score
-- =============================================
SELECT 
    p.product_id,
    p.product_name,
    p.category,

    SUM(s.quantity) AS total_sold,
    SUM(s.total_price) AS revenue,

    -- Revenue per unit (proxy for margin power)
    SUM(s.total_price) / NULLIF(SUM(s.quantity), 0) AS avg_unit_value,

    -- Popularity score
    COUNT(DISTINCT s.transaction_id) AS transaction_count,

    -- Simple optimization score
    (SUM(s.quantity) * (SUM(s.total_price) / NULLIF(SUM(s.quantity), 0))) AS optimization_score

FROM Fact_Sales s
JOIN Dim_Products p ON s.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY optimization_score DESC;
-- =============================================
-- 3. Machine Optimization Strategy
-- =============================================
SELECT 
    m.machine_id,
    m.location_zone,
    m.has_led_strip,

    SUM(s.quantity) AS total_sales,
    SUM(s.total_price) AS revenue,

    AVG(s.quantity) AS avg_items_per_transaction,

    CASE 
        WHEN m.is_low_light = TRUE AND m.has_led_strip = FALSE THEN 'INSTALL LED'
        WHEN SUM(s.quantity) < 10 THEN 'LOW PERFORMER - REVIEW PRODUCT MIX'
        WHEN SUM(s.total_price) > 1000 THEN 'HIGH PERFORMER - SCALE STOCK'
        ELSE 'NORMAL'
    END AS recommendation

FROM Fact_Sales s
JOIN Dim_Vending_Machines m ON s.machine_id = m.machine_id
GROUP BY m.machine_id, m.location_zone, m.has_led_strip, m.is_low_light;
-- =============================================
-- 4. Inventory Allocation Logic
-- =============================================
SELECT 
    p.product_id,
    p.product_name,

    SUM(s.quantity) AS demand,

    CASE 
        WHEN SUM(s.quantity) > 100 THEN 'HIGH ALLOCATION (80%)'
        WHEN SUM(s.quantity) > 50 THEN 'MEDIUM ALLOCATION (50%)'
        ELSE 'LOW ALLOCATION (20%)'
    END AS suggested_stock_ratio

FROM Fact_Sales s
JOIN Dim_Products p ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name;
