-- =============================================
-- 1. Restock Recommendation Engine
-- =============================================
-- วัตถุประสงค์: คำนวณอัตราความเร็วในการขายและคาดการณ์จำนวนวันที่สินค้าจะหมด (Days to Stockout)
WITH sales_velocity AS (
    SELECT 
        s.product_id,
        SUM(s.quantity) AS total_sold,
        COUNT(DISTINCT DATE(s.sale_timestamp)) AS active_days,
        -- หาค่าเฉลี่ยความต้องการซื้อต่อวัน
        SUM(s.quantity) / NULLIF(COUNT(DISTINCT DATE(s.sale_timestamp)), 0) AS avg_daily_demand
    FROM Fact_Sales s
    WHERE s.status = 'completed'
    GROUP BY s.product_id
),
current_inventory AS (
    -- เชื่อมโยงสต็อกฐาน (Baseline) สมมติที่ 50 ชิ้นต่อสินค้าแต่ละชนิด
    SELECT 
        product_id,
        50 AS current_stock
    FROM Dim_Products
)

SELECT 
    p.product_id,
    p.product_name,
    p.category,
    sv.total_sold,
    sv.avg_daily_demand,
    ci.current_stock,
    
    -- คำนวณจำนวนวันที่เหลืออยู่ก่อนที่สินค้าจะหมดตู้
    ROUND(ci.current_stock / NULLIF(sv.avg_daily_demand, 0), 2) AS days_to_stockout,

    -- ระบบไฟสัญญาณเตือนการเติมสินค้า (🔴 🟡 🟢) สำหรับนำไปใช้บน Dashboard
    CASE 
        WHEN ci.current_stock / NULLIF(sv.avg_daily_demand, 0) < 2 THEN '🔴 URGENT RESTOCK'
        WHEN ci.current_stock / NULLIF(sv.avg_daily_demand, 0) < 5 THEN '🟡 RESTOCK SOON'
        ELSE '🟢 OK'
    END AS restock_priority
FROM sales_velocity sv
JOIN current_inventory ci ON sv.product_id = ci.product_id
JOIN Dim_Products p ON p.product_id = sv.product_id;


-- =============================================
-- 2. Product Profitability & Popularity Score
-- =============================================
-- วัตถุประสงค์: แมตช์ตารางยอดขายกับตารางสินค้า เพื่อหาไอเทมทำเงินสูงสุดไปทำกราฟแท่งบน Dashboard
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price AS unit_price,

    SUM(s.quantity) AS total_sold,
    -- คำนวณรายได้จากราคาขายในตารางสินค้าหลัก
    SUM(s.quantity * p.price) AS total_revenue,

    -- Popularity score วัดจากจำนวนธุรกรรมที่เกิดขึ้น
    COUNT(DISTINCT s.transaction_id) AS transaction_count,

    -- Optimization score สำหรับใช้จัดอันดับสินค้าเชิงกลยุทธ์
    ROUND((SUM(s.quantity) * p.price), 2) AS optimization_score

FROM Fact_Sales s
JOIN Dim_Products p ON s.product_id = p.product_id
WHERE s.status = 'completed'
GROUP BY p.product_id, p.product_name, p.category, p.price
ORDER BY optimization_score DESC;


-- =============================================
-- 3. Machine Optimization Strategy
-- =============================================
-- วัตถุประสงค์: ตรวจสอบประสิทธิภาพของแต่ละตู้ตามทำเลและสภาพแวดล้อม (มุมมืด/การติดไฟ LED)
SELECT 
    m.machine_id,
    m.location_zone,
    m.is_low_light,
    m.has_led_strip,

    SUM(s.quantity) AS total_sales_units,
    -- รวมยอดขายสินค้าในแต่ละสาขา/ตู้
    SUM(s.quantity * p.price) AS total_revenue,

    CASE 
        -- เงื่อนไขเชิงธุรกิจ: ถ้าตู้อยู่ในมุมมืด แต่ยังไม่ได้ติดไฟ LED -> แนะนำให้ไปติดตั้งด่วน
        WHEN m.is_low_light = TRUE AND m.has_led_strip = FALSE THEN '💡 INSTALL LED IMMEDIATELY'
        -- ถ้าตู้ไหนขายได้น้อยกว่า 5 ชิ้นในช่วงกะวิเคราะห์ -> ถือว่าเป็นจุดขายอืด ต้องปรับเปลี่ยนประเภทสินค้า
        WHEN SUM(s.quantity) < 5 THEN '⚠️ LOW PERFORMER - REVIEW PRODUCT MIX'
        -- ถ้าตู้ไหนทำเงินได้สูง -> แนะนำให้ขยายขนาดความจุสต็อกเพิ่ม
        WHEN SUM(s.quantity * p.price) > 300 THEN '🚀 HIGH PERFORMER - SCALE STOCK CAPACITY'
        ELSE '✅ NORMAL PERFORMANCE'
    END AS strategic_recommendation

FROM Fact_Sales s
JOIN Dim_Vending_Machines m ON s.machine_id = m.machine_id
JOIN Dim_Products p ON s.product_id = p.product_id
GROUP BY m.machine_id, m.location_zone, m.is_low_light, m.has_led_strip;


-- =============================================
-- 4. Inventory Allocation Logic (ABC/Ratio Suggestion)
-- =============================================
-- วัตถุประสงค์: จัดสรรสัดส่วนการวางสินค้าตามสถิติความต้องการ (Demand)
SELECT 
    p.product_id,
    p.product_name,
    SUM(s.quantity) AS total_demand_units,

    -- แนะนำสัดส่วนพื้นที่บนหน้าร้านตู้ Vending Machine 
    CASE 
        WHEN SUM(s.quantity) >= 5 THEN 'HIGH ALLOCATION (80% Space)'
        WHEN SUM(s.quantity) >= 2 THEN 'MEDIUM ALLOCATION (50% Space)'
        ELSE 'LOW ALLOCATION (20% Space)'
    END AS suggested_stock_ratio
FROM Fact_Sales s
JOIN Dim_Products p ON p.product_id = s.product_id
WHERE s.status = 'completed'
GROUP BY p.product_id, p.product_name
ORDER BY total_demand_units DESC;
