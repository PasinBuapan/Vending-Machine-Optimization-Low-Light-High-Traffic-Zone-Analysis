# 🥤 Vending Machine Performance Optimization in Hospital Corridor Environments
**Exploratory Data Analysis of Environmental, Behavioral, and Product Mix Factors Affecting Low-Light Retail Performance**

## 📌 Project Overview

This project demonstrates exploratory data analysis and optimization thinking applied to vending machine performance in low-light, high-traffic hospital environments.

The goal is to understand how environmental visibility, customer behavior patterns, and product mix influence sales performance and revenue distribution.

The analysis is based on a simulated dataset designed to reflect realistic vending machine transactions and operational constraints.

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
The project uses a **star-schema data model** to support analytical querying using our simulated dataset (`vending_machine_sales_mock.csv`):
* `Fact_Sales`: Transaction-level sales data. (timestamp, quantity, revenue, product, machine)
* `Dim_Products`: Product master data. (category, price, menu type)
* `Dim_Toppings`: Add-on products and upsell components.
* `Dim_Vending_Machines`: Environmental attributes (location, lighting conditions, LED presence)
This structure is designed to support scalable analytics across multiple dimensions: time, product, and environment.
---
## 🔍 Methodology

The analysis follows a structured approach:

### 1. Descriptive Analytics
  * Sales performance by machine, product, and time
  * Revenue and transaction distribution
### 2. Segment Analysis
  * Low-light vs LED-equipped machines
  * Night-time (23:00–05:00) demand behavior
  * Product category performance
### 3. Cross-Dimensional Analysis
  * Environment × performance (lighting vs sales)
  * Location × machine efficiency
### 4. Product Mix Analysis
  * Product popularity
  * Topping attachment behavior
  * Revenue contribution by category
---
## 📊 Key Insights
🔗 [Click here to view Live Demo & Run Code on Google Colab](https://colab.research.google.com/drive/15jbEH3-GUm7wu2E5CMUJinTVOpVuKLNi?usp=sharing)

| ⚠️ Note: Results are based on simulated data and should be interpreted as directional insights.

<img width="558" height="393" alt="Mock data (Graph)" src="https://github.com/user-attachments/assets/56d48669-92d3-40f5-94ac-99f73201269e" />


### 💡 1. Visibility and Sales Performance (LED Hypothesis)
Machines equipped with LED lighting in low-light zones showed **higher sales performance compared to non-LED machines** in the simulated dataset.

* LED-equipped machine (M002) showed higher revenue and transaction volume
* Non-LED machine (M001) underperformed in comparable conditions

**Insight**: Improved visibility may increase impulse purchasing behavior in low-light environments.

### 2. ☕ Night-Time Demand Patterns (23:00 - 05:00)
Late-night sales are heavily concentrated in **caffeine-based products**, reflecting shift-worker consumption behavior.

* Caffeine products dominate night-time revenue share
* Soft drinks and juices show significantly lower demand

**Insight**: Inventory allocation for machines located in hospital corridor environments should be optimized toward caffeine-heavy product mix to align with observed night-time demand patterns.

### 3. 🎯 Product & Upsell Behavior
Topping analysis shows meaningful attachment behavior:

* Extra espresso shots show the highest attachment rate
* Add-ons contribute additional revenue per transaction

**Insight**: Upselling opportunities exist even in low-interaction vending environments.

---

## 💡 Recommendations

Based on the analysis, the following operational strategies are suggested:

### 1. Improve Visibility in Low-Light Zones
  * Consider installing LED lighting in underperforming machines
  * Expected to improve visibility and potentially increase transaction volume
### 2. Optimize Product Allocation for Night Shifts
  * Increase allocation of caffeine-based products in high-traffic nighttime locations
  * Reduce low-demand categories during night hours
### 3. Enhance Upselling Strategy
  * Promote high-performing toppings (e.g., espresso shots)
  * Consider bundling or default recommendations for add-ons

---

## ⚠️ Limitations
* Dataset is simulated and does not represent real-world transactional noise
* No external demand factors (weather, hospital occupancy, events) included
* A/B comparisons are observational and not statistically controlled experiments
* Results should be interpreted as hypothesis-generating rather than causal proof

---

## 🧠 Tools & Stack
* SQL (Data modeling & analysis)
* Star Schema design
* Aggregation & segmentation queries
* Business logic-based optimization rules

---

## 📌 Conclusion

This project demonstrates how vending machine performance can be analyzed through the lens of **environmental conditions, user behavior, and product mix strategy**.

While based on simulated data, the framework is designed to be extendable to real-world datasets for operational decision-making and optimization.

---

##📎 Future Improvements
* Incorporate real-time inventory tracking
* Add demand forecasting model (time-series analysis)
* Introduce statistical testing for A/B experiments
* Build dashboard for operational monitoring (Power BI / Tableau).

---
