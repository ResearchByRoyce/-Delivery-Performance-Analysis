## 📊 SQL Operations Performance Analysis

This project analyzes ecommerce shipment operations using PostgreSQL. It focuses on late deliveries, warehouse performance, shipment method performance, service pressure, product-related risk, and business recommendations.

## 🧾 Project Overview

The objective of this project is to measure operational performance and identify possible causes of delivery issues. SQL is used to clean the dataset, create calculated fields, calculate delivery KPIs, compare warehouse and shipment performance, and find high-risk operational segments.

## 🛠️ Tools Used

**PostgreSQL** — For querying, cleaning, KPI calculation, and operations analysis  
👉 SQL Code

**pgAdmin** — For running SQL scripts and viewing query results  
👉 Query Results

**Excel / CSV** — Raw dataset in spreadsheet format  
👉 Dataset File

## 📂 Dataset Description

Dataset: [Kaggle Customer Analytics / E-Commerce Shipping Data](https://www.kaggle.com/datasets/prachi13/customer-analytics)

The dataset contains ecommerce shipment records. Each row represents one product shipment and includes warehouse, shipment method, customer-care, product, discount, weight, and delivery-status information.

Important note: Kaggle defines `Reached.on.Time_Y.N` as `1` when the product did **not** reach on time and `0` when the product reached on time.

| Column Name | Description |
| --- | --- |
| `ID` | Unique shipment record ID |
| `Warehouse_block` | Warehouse block or fulfillment area |
| `Mode_of_Shipment` | Shipment method used |
| `Customer_care_calls` | Number of customer-care calls |
| `Customer_rating` | Customer rating score |
| `Cost_of_the_Product` | Product cost |
| `Prior_purchases` | Number of previous purchases |
| `Product_importance` | Product importance level |
| `Gender` | Customer gender |
| `Discount_offered` | Discount offered on the product |
| `Weight_in_gms` | Product weight in grams |
| `Reached.on.Time_Y.N` | Delivery status, where `1` means late and `0` means on time |

## ⚠️ Data Limitation

This dataset does not include real order dates, ship dates, delivery dates, region, vendor, carrier, or cancellation fields. To keep the analysis honest, the SQL only uses the fields available in the dataset.

- Warehouse block is used as the fulfillment area.
- Mode of shipment is used as the shipping method.
- Product importance, weight, cost, and discount are used as product-related risk factors.
- Customer-care calls and customer rating are used as service-pressure signals.
- A sequence-based `analysis_month` is created from shipment ID only to demonstrate time-period SQL logic.
- The dataset does not include cancellations, so this project does not claim a real cancellation rate.

## ❓ Questions Answered Using SQL

### ✅ Basic Queries:

- Total shipments
- Total late shipments
- Overall late delivery rate
- On-time vs late shipment count
- Shipment count by warehouse block
- Shipment count by shipment mode
- Data-quality checks

### 🔁 Intermediate Queries:

- Late delivery rate by warehouse block
- Late delivery rate by shipment mode
- Customer-care call patterns
- Product importance and delivery risk
- Discount impact on delivery performance
- Weight group performance
- Customer rating comparison

### 🔍 Advanced Queries:

- Monthly operational trend using sequence-based `analysis_month`
- Warehouse performance ranking using window functions
- Shipment mode performance comparison
- High-risk segment identification
- Product-risk grouping using `CASE WHEN`
- Operational recommendation query

## 📈 Key Insights

- 🚚 Late delivery rate helps measure the overall health of shipment operations.
- 🏬 Warehouse block analysis shows which fulfillment areas may need attention.
- 📦 Product weight, cost, discount, and importance can help explain operational risk.
- 📞 Higher customer-care calls may show service pressure or delivery problems.
- ⭐ Customer rating can be compared with delivery status to understand customer experience.
- 📉 High-risk warehouse and shipment combinations should be reviewed first.
- 🛠️ Operational improvements should focus on the segments with the highest late delivery rates.

## ✅ SQL Analysis Highlights

- Delivery status classification using `CASE WHEN`
- Operational KPI calculations
- Late delivery rate analysis
- Warehouse and shipment mode comparison
- Product-related risk analysis
- Service-pressure analysis using customer-care calls
- Window functions for ranking and trend comparison
- Recommendation query for business action

## 📂 Main Table Created

| Table Name | Purpose |
| --- | --- |
| `ecommerce_shipping_raw` | Raw imported ecommerce shipping dataset |

## 🧠 SQL Skills Shown

- `CREATE TABLE`
- `CASE WHEN`
- `COUNT`, `SUM`, and `AVG`
- Percentage calculations
- Data-quality checks
- Common table expressions
- Views
- `DATE_TRUNC`
- Interval logic
- Window functions such as `RANK`, `DENSE_RANK`, `LAG`, and `NTILE`

## 💡 Business Recommendations

- Review warehouse blocks with the highest late delivery rates.
- Improve shipment methods that show weaker delivery performance.
- Monitor high-importance and heavy products more closely.
- Investigate cases with high customer-care calls because they may show service issues.
- Use high-risk operational segments to prioritize process improvement.
- Replace the sequence-based month with real order or delivery dates if a richer dataset is available.

## 🏁 Conclusion

This project demonstrates how SQL can be used for operations performance analysis beyond basic sales reporting. It turns shipment data into useful KPIs, highlights possible delivery-risk drivers, and supports business decisions around warehouse performance, shipment methods, service pressure, and process improvement.


