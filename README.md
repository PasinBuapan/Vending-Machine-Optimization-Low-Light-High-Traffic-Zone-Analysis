# 🥤 Vending Machine Performance Optimization in Hospital Corridor Environments
**Exploratory Data Analysis of Environmental, Behavioral, and Product Mix Factors Affecting Low-Light Retail Performance**

## 📌 Project Overview

This project demonstrates exploratory data analysis and optimization thinking applied to vending machine performance in low-light, high-traffic hospital environments.

The goal is to understand how environmental visibility, customer behavior patterns, and product mix influence sales performance and revenue distribution.

The analysis is based on a simulated dataset designed to reflect realistic vending machine transactions and operational constraints, implemented using PostgreSQL 18 with a star-schema design for scalable analytics.

---
## 🏥 Business Context

Hospital corridor vending machines operate in a unique environment where visibility, shift-worker behavior, and limited inventory capacity can influence purchasing decisions. 

Understanding these factors can help operators improve product placement, inventory allocation, and machine performance.

---

## 🎯 Business Problem

Vending machines placed in hospital walkways often operate under constraints that may affect sales performance:

* Low visibility in dimly lit corridors
* High concentration of shift workers during nighttime hours
* Limited product selection and fixed inventory slots

This project investigates:

1. Does improving visibility (e.g., LED installation) impact sales performance?
2. Which product categories perform best during late-night hours?
3. What product and topping mix can maximize revenue in constrained vending environments?

---
## 🧱 Data Architecture

The project uses a **star-schema data model** implemented in PostgreSQL 18 to support analytical querying across multiple dimensions: time, product, location, and environmental conditions.

### Tables Overview

| Table Name | Type | Purpose |
|---|---|---|
| `fact_sales` | Fact | Transaction-level sales data (timestamp, quantity, revenue, product, machine) |
| `dim_products` | Dimension | Product master data (category, price, menu type) |
| `dim_toppings` | Dimension | Add-on products and upsell components |
| `dim_vending_machines` | Dimension | Environmental attributes (location, lighting conditions, LED presence) |

### Key Design Features

**PostgreSQL 18 Capabilities Used:**
- **Generated columns**: `total_price` automatically calculated as `(product_price + topping_price) * quantity`
- **Triggers**: Automatic timestamp management for `updated_at` columns across all dimension tables
- **Constraints**: CHECK constraints for data validation (e.g., `price >= 0`, `quantity > 0`)
- **Foreign keys**: Referential integrity with ON DELETE RESTRICT and ON UPDATE CASCADE
- **Indexes**: 9 strategic indexes on fact table (foreign keys, temporal, status) and dimension tables (location, category)

### Sample Data Test Scenario

The dataset includes a simulated night shift period (23:00 - 05:00 hrs, May 23, 2026) testing the LED hypothesis across three machines:

| Machine | Location | Lighting | LED? | Expected Performance | Purpose |
|---|---|---|---|---|---|
| **M001** | Old Building Connector | Dark | No | Low (control) | Baseline: dark without intervention |
| **M002** | OPD Front Desk | Dark | Yes | Higher (LED effect) | Treatment: LED installed |
| **M003** | Building 1 Main Corridor | Well-lit | No | Normal (baseline) | Reference: standard lighting |

This design enables direct comparison of LED impact in equivalent low-light environments (M001 vs M002) while maintaining a well-lit control (M003).

---
## 🔍 Methodology

The analysis follows a structured approach:

### 1. Descriptive Analytics
  * Sales performance by machine, product, and time
  * Revenue and transaction distribution
  * Query: Analysis.sql Queries 1, 3, 4, 6, 7

### 2. Segment Analysis
  * Low-light vs LED-equipped machines (LED hypothesis testing)
  * Night-time (23:00–05:00) demand behavior patterns
  * Product category performance during different periods
  * Query: Analysis.sql Queries 2, 5, 8

### 3. Cross-Dimensional Analysis
  * Environment × performance (lighting vs sales outcomes)
  * Location × machine efficiency
  * Product × machine location preferences
  * Query: Analysis.sql Queries 8, 10

### 4. Product Mix Analysis
  * Product popularity and revenue contribution
  * Topping attachment rates and upsell behavior
  * Category performance rankings
  * Query: Analysis.sql Queries 4, 5; Optimization.sql Queries 2, 4

### 5. Business Intelligence Layer
  * **Restock Recommendation Engine**: Sales velocity forecasting and inventory alerts (Optimization.sql Query 1)
  * **Product Profitability Analysis**: Revenue-weighted product ranking (Optimization.sql Query 2)
  * **Machine Performance Recommendations**: Strategic guidance based on location and LED status (Optimization.sql Query 3)
  * **ABC Inventory Analysis**: Shelf space allocation optimization (Optimization.sql Query 4)

---
## 📊 Key Insights
🔗 [Click here to view Live Demo & Run Code on Google Colab](https://colab.research.google.com/drive/15jbEH3-GUm7wu2E5CMUJinTVOpVuKLNi?usp=sharing)

| ⚠️ Note: Results are based on simulated data and should be interpreted as directional insights.

<img width="558" height="393" alt="Mock data (Graph)" src="https://github.com/user-attachments/assets/56d48669-92d3-40f5-94ac-99f73201269e" />

### 💡 1. Visibility and Sales Performance (LED Hypothesis)
Machines equipped with LED lighting in low-light zones showed **higher sales performance compared to non-LED machines** in the simulated dataset.

* LED-equipped machine (M002 in dark zone): 5 transactions, 6 units sold, 465.00 THB revenue
* Non-LED machine (M001 in equivalent dark zone): 2 transactions, 2 units sold, 105.00 THB revenue
* Performance gap: **5 vs. 2 transactions, and 465.00 vs. 105.00 THB revenue within this simulated scenario**

**Insight**: The simulated dataset suggests a potential positive relationship between LED installation and sales performance in low-light environments, indicating that improved visibility could be a high-ROI operational intervention.

### 2. ☕ Night-Time Demand Patterns (23:00 - 05:00)
Late-night sales are heavily concentrated in **caffeine-based products**, reflecting shift-worker consumption behavior.

* Caffeine products dominate night-time revenue share
* Soft drinks and juices show significantly lower demand
* Extra espresso shots (T01) show a notable attachment trend

**Insight**: Inventory allocation for machines located in hospital corridor environments should prioritize caffeine-based products to align with observed night-time demand patterns.

### 3. 🎯 Product & Upsell Behavior
Topping analysis shows meaningful attachment behavior even in low-interaction vending environments:

* Extra espresso shots show the highest attachment rate
* Add-ons show a directional increase in average transaction value within the simulated environment.
* "No Topping" (T03) is still selected in **the majority** of transactions, potentially indicating budget-conscious purchases

**Insight**: Upselling opportunities exist even in low-interaction vending environments. Strategic placement of topping prompts may increase average transaction value and warrants further testing.

---

## 💡 Recommendations

Based on the analysis, the following operational strategies are suggested:

### 1. Improve Visibility in Low-Light Zones
  * Consider installing LED lighting in dark corridor machines (M001-type locations)
  * Potential impact: Increased transaction volume based on observed patterns in the simulated dataset.
  * Implementation priority: HIGH for `is_low_light = TRUE` machines

### 2. Optimize Product Allocation for Night Shifts
  * Increase caffeine-based product allocation in high-traffic night locations
  * Reduce low-demand juice and beverage categories during evening restock cycles
  * Use Optimization.sql Query 4 (ABC Analysis) to guide restocking decisions

### 3. Enhance Upselling Strategy
  * Promote high-performing toppings (e.g., espresso shots) through signage or bundle offers
  * Target all caffeine products during night-shift hours
  * Potential impact: Higher average transaction value through increased topping adoption.

---

## ⚠️ Limitations
* Dataset is simulated and does not represent real-world transactional noise
* No external demand factors (weather, hospital occupancy, events) included
* A/B comparisons are observational and not statistically controlled experiments
* Results should be interpreted as hypothesis-generating rather than causal proof

---

## 🧠 Tools & Stack

* **PostgreSQL 18**: Used as the primary development and validation environment.
* **SQL**: Data modeling, aggregation, time-series segmentation, business logic implementation, and PostgreSQL-compatible analytical query development (validated on PostgreSQL 18; compatible with PostgreSQL 15+ syntax).
* **Star Schema Design**: Dimensional modeling for scalable analytics.
* **Analytics Queries**: 10 analytical queries (Analysis.sql) + 4 optimization queries (Optimization.sql).

---

## 📌 Conclusion

This project demonstrates how vending machine performance can be analyzed through the lens of **environmental conditions, user behavior, and product mix strategy**.

While based on simulated data, the framework is designed to be extendable to real-world datasets for operational decision-making and optimization. The PostgreSQL implementation provides a Production-inspired architecture for inventory management, performance monitoring, and location-based optimization.

---

## 📎 Future Improvements
* Incorporate real-time inventory tracking
* Add demand forecasting model (time-series analysis)
* Introduce statistical testing for A/B experiments
* Build dashboard for operational monitoring (Power BI / Tableau)

---
