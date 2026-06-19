CREATE TABLE ecommerce_shipping_raw (
    id INTEGER PRIMARY KEY,
    warehouse_block VARCHAR(5),
    mode_of_shipment VARCHAR(20),
    customer_care_calls INTEGER,
    customer_rating INTEGER,
    cost_of_the_product NUMERIC(10, 2),
    prior_purchases INTEGER,
    product_importance VARCHAR(20),
    gender VARCHAR(10),
    discount_offered NUMERIC(10, 2),
    weight_in_gms INTEGER,
    reached_on_time_y_n INTEGER
);

-- Check imported data after loading the CSV.
SELECT *
FROM ecommerce_shipping_raw
LIMIT 10;

-- MILESTONE 1: UNDERSTAND THE OPERATIONAL FLOW

--This section checks the shipment volume, dimensions available for operational analysis, and whether the raw data is clean enough for KPI work.

-- 1.1 Overall dataset profile
SELECT
    COUNT(*) AS total_shipments,
    COUNT(DISTINCT warehouse_block) AS warehouse_blocks,
    COUNT(DISTINCT mode_of_shipment) AS shipment_modes,
    COUNT(DISTINCT product_importance) AS product_importance_levels,
    MIN(cost_of_the_product) AS min_product_cost,
    MAX(cost_of_the_product) AS max_product_cost,
    MIN(weight_in_gms) AS min_weight_gms,
    MAX(weight_in_gms) AS max_weight_gms
FROM ecommerce_shipping_raw;


-- 1.2 Available operational categories
SELECT
    warehouse_block,
    mode_of_shipment,
    product_importance,
    COUNT(*) AS shipment_count
FROM ecommerce_shipping_raw
GROUP BY
    warehouse_block,
    mode_of_shipment,
    product_importance
ORDER BY
    shipment_count DESC;


-- 1.3 Data-quality checks before analysis
SELECT
    SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS missing_id,
    SUM(CASE WHEN warehouse_block IS NULL THEN 1 ELSE 0 END) AS missing_warehouse_block,
    SUM(CASE WHEN mode_of_shipment IS NULL THEN 1 ELSE 0 END) AS missing_mode_of_shipment,
    SUM(CASE WHEN customer_care_calls IS NULL THEN 1 ELSE 0 END) AS missing_customer_care_calls,
    SUM(CASE WHEN customer_rating IS NULL THEN 1 ELSE 0 END) AS missing_customer_rating,
    SUM(CASE WHEN cost_of_the_product IS NULL THEN 1 ELSE 0 END) AS missing_cost,
    SUM(CASE WHEN prior_purchases IS NULL THEN 1 ELSE 0 END) AS missing_prior_purchases,
    SUM(CASE WHEN product_importance IS NULL THEN 1 ELSE 0 END) AS missing_product_importance,
    SUM(CASE WHEN discount_offered IS NULL THEN 1 ELSE 0 END) AS missing_discount,
    SUM(CASE WHEN weight_in_gms IS NULL THEN 1 ELSE 0 END) AS missing_weight,
    SUM(CASE WHEN reached_on_time_y_n IS NULL THEN 1 ELSE 0 END) AS missing_delivery_status
FROM ecommerce_shipping_raw;


/*==============================================================================
MILESTONE 2: CREATE CALCULATED OPERATIONAL FIELDS

These CASE fields turn raw shipment attributes into business-friendly indicators:
- delivery status
- late/on-time flag
- warehouse location
- route type
- service-pressure band
- product weight/cost/discount bands
- sequence-based analysis month
==============================================================================*/

DROP VIEW IF EXISTS shipping_operations_enriched;

CREATE VIEW shipping_operations_enriched AS
SELECT
    id,
    warehouse_block,
    mode_of_shipment,
    customer_care_calls,
    customer_rating,
    cost_of_the_product,
    prior_purchases,
    product_importance,
    gender,
    discount_offered,
    weight_in_gms,
    reached_on_time_y_n,

    CASE
        WHEN reached_on_time_y_n = 1 THEN 1
        WHEN reached_on_time_y_n = 0 THEN 0
        ELSE NULL
    END AS late_delivery_flag,

    CASE
        WHEN reached_on_time_y_n = 1 THEN 'Late'
        WHEN reached_on_time_y_n = 0 THEN 'On Time'
        ELSE 'Unknown'
    END AS delivery_status,

    CASE
        WHEN customer_care_calls >= 6 THEN 'High service pressure'
        WHEN customer_care_calls >= 4 THEN 'Moderate service pressure'
        ELSE 'Low service pressure'
    END AS service_pressure_band,

    CASE
        WHEN customer_rating <= 2 THEN 'Low rating'
        WHEN customer_rating = 3 THEN 'Neutral rating'
        WHEN customer_rating >= 4 THEN 'High rating'
        ELSE 'Unknown rating'
    END AS customer_rating_band,

    CASE
        WHEN prior_purchases >= 5 THEN 'Repeat customer'
        WHEN prior_purchases >= 3 THEN 'Developing customer'
        ELSE 'Newer customer'
    END AS customer_history_segment,

    CASE
        WHEN cost_of_the_product >= 250 THEN 'High cost'
        WHEN cost_of_the_product >= 170 THEN 'Mid cost'
        ELSE 'Low cost'
    END AS cost_band,

    CASE
        WHEN discount_offered >= 40 THEN 'High discount'
        WHEN discount_offered >= 10 THEN 'Moderate discount'
        ELSE 'Low discount'
    END AS discount_band,

    CASE
        WHEN weight_in_gms >= 5000 THEN 'Heavy'
        WHEN weight_in_gms >= 2500 THEN 'Medium weight'
        ELSE 'Light'
    END AS weight_band,

    CASE
        WHEN product_importance = 'high' AND weight_in_gms >= 5000 THEN 'High-priority heavy item'
        WHEN product_importance = 'high' THEN 'High-priority standard item'
        WHEN weight_in_gms >= 5000 THEN 'Heavy standard-priority item'
        ELSE 'Standard item'
    END AS shipment_complexity,

    DATE_TRUNC(
        'month',
        DATE '2021-01-01' + (((id - 1) / 920)::INTEGER * INTERVAL '1 month')
    )::DATE AS analysis_month
FROM ecommerce_shipping_raw;


-- 2.1 Preview the enriched operating table
SELECT *
FROM shipping_operations_enriched
ORDER BY id
LIMIT 25;


/*==============================================================================
MILESTONE 3: CREATE OPERATIONAL KPIS

KPIs:
- late delivery rate
- on-time delivery rate
- average customer-care calls
- average rating
- cancellation-rate placeholder
- performance by month
- performance by warehouse block
- performance by route
==============================================================================*/

-- 3.1 Overall delivery performance KPI
SELECT
    COUNT(*) AS total_shipments,
    SUM(late_delivery_flag) AS late_shipments,
    ROUND(100.0 * AVG(late_delivery_flag), 2) AS late_delivery_rate_pct,
    ROUND(100.0 * AVG(1 - late_delivery_flag), 2) AS on_time_delivery_rate_pct,
    ROUND(AVG(customer_care_calls), 2) AS avg_customer_care_calls,
    ROUND(AVG(customer_rating), 2) AS avg_customer_rating,
    ROUND(AVG(cost_of_the_product), 2) AS avg_product_cost,
    ROUND(AVG(weight_in_gms), 2) AS avg_weight_gms,
    NULL::NUMERIC AS cancellation_rate_pct_not_available
FROM shipping_operations_enriched;


-- 3.2 Performance by warehouse location
SELECT
    warehouse_block,
    COUNT(*) AS total_shipments,
    SUM(late_delivery_flag) AS late_shipments,
    ROUND(100.0 * AVG(late_delivery_flag), 2) AS late_delivery_rate_pct,
    ROUND(AVG(customer_care_calls), 2) AS avg_customer_care_calls,
    ROUND(AVG(customer_rating), 2) AS avg_customer_rating
FROM shipping_operations_enriched
GROUP BY warehouse_block
ORDER BY
    late_delivery_rate_pct DESC,
    total_shipments DESC;


-- 3.3 Performance by shipment route/mode
SELECT
    mode_of_shipment,
    COUNT(*) AS total_shipments,
    SUM(late_delivery_flag) AS late_shipments,
    ROUND(100.0 * AVG(late_delivery_flag), 2) AS late_delivery_rate_pct,
    ROUND(AVG(customer_care_calls), 2) AS avg_customer_care_calls,
    ROUND(AVG(customer_rating), 2) AS avg_customer_rating
FROM shipping_operations_enriched
GROUP BY mode_of_shipment
ORDER BY
    late_delivery_rate_pct DESC,
    total_shipments DESC;


-- 3.4 Month-like operational trend using sequence-based analysis_month
SELECT
    analysis_month,
    COUNT(*) AS total_shipments,
    SUM(late_delivery_flag) AS late_shipments,
    ROUND(100.0 * AVG(late_delivery_flag), 2) AS late_delivery_rate_pct,
    ROUND(AVG(customer_care_calls), 2) AS avg_customer_care_calls,
    ROUND(AVG(customer_rating), 2) AS avg_customer_rating
FROM shipping_operations_enriched
GROUP BY analysis_month
ORDER BY analysis_month;


/*==============================================================================
MILESTONE 4: DEEP DIVE ROOT-CAUSE STYLE ANALYSIS

This section looks for patterns behind poor operational performance:
- worst warehouse blocks
- worst shipment modes
- product importance issues
- discount and weight effects
- service pressure
- monthly deterioration
==============================================================================*/

-- 4.1 Rank warehouse blocks by late-delivery rate
WITH warehouse_performance AS (
    SELECT
        warehouse_block,
        COUNT(*) AS total_shipments,
        SUM(late_delivery_flag) AS late_shipments,
        AVG(late_delivery_flag) AS late_delivery_rate,
        AVG(customer_care_calls) AS avg_customer_care_calls,
        AVG(customer_rating) AS avg_customer_rating
    FROM shipping_operations_enriched
    GROUP BY warehouse_block
)
SELECT
    warehouse_block,
    total_shipments,
    late_shipments,
    ROUND(100.0 * late_delivery_rate, 2) AS late_delivery_rate_pct,
    ROUND(avg_customer_care_calls, 2) AS avg_customer_care_calls,
    ROUND(avg_customer_rating, 2) AS avg_customer_rating,
    RANK() OVER (ORDER BY late_delivery_rate DESC) AS worst_warehouse_rank
FROM warehouse_performance
ORDER BY worst_warehouse_rank;


-- 4.2 Rank route performance within each warehouse
WITH route_performance AS (
    SELECT
        warehouse_block,
        mode_of_shipment,
        COUNT(*) AS total_shipments,
        SUM(late_delivery_flag) AS late_shipments,
        AVG(late_delivery_flag) AS late_delivery_rate
    FROM shipping_operations_enriched
    GROUP BY
        warehouse_block,
        mode_of_shipment
)
SELECT
    warehouse_block,
    mode_of_shipment,
    total_shipments,
    late_shipments,
    ROUND(100.0 * late_delivery_rate, 2) AS late_delivery_rate_pct,
    DENSE_RANK() OVER (
        PARTITION BY warehouse_block
        ORDER BY late_delivery_rate DESC, total_shipments DESC
    ) AS route_risk_rank_within_warehouse
FROM route_performance
ORDER BY
    warehouse_block,
    route_risk_rank_within_warehouse;


-- 4.3 Product groups associated with late deliveries
SELECT
    product_importance,
    shipment_complexity,
    weight_band,
    cost_band,
    COUNT(*) AS total_shipments,
    SUM(late_delivery_flag) AS late_shipments,
    ROUND(100.0 * AVG(late_delivery_flag), 2) AS late_delivery_rate_pct,
    ROUND(AVG(discount_offered), 2) AS avg_discount_offered,
    ROUND(AVG(customer_care_calls), 2) AS avg_customer_care_calls
FROM shipping_operations_enriched
GROUP BY
    product_importance,
    shipment_complexity,
    weight_band,
    cost_band
HAVING COUNT(*) >= 25
ORDER BY
    late_delivery_rate_pct DESC,
    total_shipments DESC;


-- 4.4 Service-pressure analysis: do higher call volumes align with late orders?
SELECT
    service_pressure_band,
    COUNT(*) AS total_shipments,
    SUM(late_delivery_flag) AS late_shipments,
    ROUND(100.0 * AVG(late_delivery_flag), 2) AS late_delivery_rate_pct,
    ROUND(AVG(customer_rating), 2) AS avg_customer_rating,
    ROUND(AVG(discount_offered), 2) AS avg_discount_offered
FROM shipping_operations_enriched
GROUP BY service_pressure_band
ORDER BY late_delivery_rate_pct DESC;


-- 4.5 Discount analysis: identify whether heavy discounts are linked to delays
SELECT
    discount_band,
    COUNT(*) AS total_shipments,
    SUM(late_delivery_flag) AS late_shipments,
    ROUND(100.0 * AVG(late_delivery_flag), 2) AS late_delivery_rate_pct,
    ROUND(AVG(cost_of_the_product), 2) AS avg_product_cost,
    ROUND(AVG(weight_in_gms), 2) AS avg_weight_gms
FROM shipping_operations_enriched
GROUP BY discount_band
ORDER BY late_delivery_rate_pct DESC;


-- 4.6 Monthly performance change using LAG window function
WITH monthly_performance AS (
    SELECT
        analysis_month,
        COUNT(*) AS total_shipments,
        AVG(late_delivery_flag) AS late_delivery_rate,
        AVG(customer_care_calls) AS avg_customer_care_calls
    FROM shipping_operations_enriched
    GROUP BY analysis_month
)
SELECT
    analysis_month,
    total_shipments,
    ROUND(100.0 * late_delivery_rate, 2) AS late_delivery_rate_pct,
    ROUND(
        100.0 * (
            late_delivery_rate
            - LAG(late_delivery_rate) OVER (ORDER BY analysis_month)
        ),
        2
    ) AS late_rate_change_vs_prior_month_pct_points,
    ROUND(avg_customer_care_calls, 2) AS avg_customer_care_calls,
    CASE
        WHEN late_delivery_rate > LAG(late_delivery_rate) OVER (ORDER BY analysis_month)
            THEN 'Worsened vs prior month'
        WHEN late_delivery_rate < LAG(late_delivery_rate) OVER (ORDER BY analysis_month)
            THEN 'Improved vs prior month'
        ELSE 'No prior month or no change'
    END AS monthly_status
FROM monthly_performance
ORDER BY analysis_month;


-- 4.7 High-risk operational segments using NTILE
WITH segment_performance AS (
    SELECT
        warehouse_block,
        mode_of_shipment,
        product_importance,
        weight_band,
        COUNT(*) AS total_shipments,
        AVG(late_delivery_flag) AS late_delivery_rate,
        AVG(customer_care_calls) AS avg_customer_care_calls
    FROM shipping_operations_enriched
    GROUP BY
        warehouse_block,
        mode_of_shipment,
        product_importance,
        weight_band
    HAVING COUNT(*) >= 30
)
SELECT
    warehouse_block,
    mode_of_shipment,
    product_importance,
    weight_band,
    total_shipments,
    ROUND(100.0 * late_delivery_rate, 2) AS late_delivery_rate_pct,
    ROUND(avg_customer_care_calls, 2) AS avg_customer_care_calls,
    NTILE(4) OVER (ORDER BY late_delivery_rate DESC, total_shipments DESC) AS operational_risk_quartile
FROM segment_performance
ORDER BY
    operational_risk_quartile,
    late_delivery_rate_pct DESC;


/*==============================================================================
MILESTONE 5: BUSINESS RECOMMENDATIONS

This final section converts findings into action-oriented recommendations.
==============================================================================*/

-- 5.1 Recommended actions by warehouse block
WITH warehouse_summary AS (
    SELECT
        warehouse_block,
        COUNT(*) AS total_shipments,
        AVG(late_delivery_flag) AS late_delivery_rate,
        AVG(customer_care_calls) AS avg_customer_care_calls,
        AVG(customer_rating) AS avg_customer_rating
    FROM shipping_operations_enriched
    GROUP BY warehouse_block
),
overall_summary AS (
    SELECT
        AVG(late_delivery_flag) AS overall_late_delivery_rate,
        AVG(customer_care_calls) AS overall_customer_care_calls
    FROM shipping_operations_enriched
)
SELECT
    w.warehouse_block,
    w.total_shipments,
    ROUND(100.0 * w.late_delivery_rate, 2) AS late_delivery_rate_pct,
    ROUND(w.avg_customer_care_calls, 2) AS avg_customer_care_calls,
    ROUND(w.avg_customer_rating, 2) AS avg_customer_rating,
    CASE
        WHEN w.late_delivery_rate > o.overall_late_delivery_rate
             AND w.avg_customer_care_calls > o.overall_customer_care_calls
            THEN 'Investigate warehouse workflow and customer-service escalation process'
        WHEN w.late_delivery_rate > o.overall_late_delivery_rate
            THEN 'Review picking, packing, dispatch, and route handoff process'
        WHEN w.avg_customer_care_calls > o.overall_customer_care_calls
            THEN 'Improve customer communication and shipment visibility'
        ELSE 'Maintain current process and monitor for volume changes'
    END AS recommendation
FROM warehouse_summary w
CROSS JOIN overall_summary o
ORDER BY
    w.late_delivery_rate DESC,
    w.total_shipments DESC;


-- 5.2 Recommended actions by product/route segment
WITH segment_summary AS (
    SELECT
        mode_of_shipment,
        product_importance,
        weight_band,
        discount_band,
        COUNT(*) AS total_shipments,
        AVG(late_delivery_flag) AS late_delivery_rate,
        AVG(customer_care_calls) AS avg_customer_care_calls
    FROM shipping_operations_enriched
    GROUP BY
        mode_of_shipment,
        product_importance,
        weight_band,
        discount_band
    HAVING COUNT(*) >= 30
)
SELECT
    mode_of_shipment,
    product_importance,
    weight_band,
    discount_band,
    total_shipments,
    ROUND(100.0 * late_delivery_rate, 2) AS late_delivery_rate_pct,
    ROUND(avg_customer_care_calls, 2) AS avg_customer_care_calls,
    CASE
        WHEN late_delivery_rate >= 0.65 AND weight_band = 'Heavy'
            THEN 'Prioritize capacity planning for heavy items on this route'
        WHEN late_delivery_rate >= 0.65 AND discount_band = 'High discount'
            THEN 'Check whether promotional demand is creating fulfillment pressure'
        WHEN late_delivery_rate >= 0.65 AND product_importance = 'high'
            THEN 'Create faster handling rules for high-importance products'
        WHEN late_delivery_rate >= 0.60
            THEN 'Monitor as elevated-risk segment and review dispatch workflow'
        ELSE 'No immediate intervention; continue routine monitoring'
    END AS recommendation
FROM segment_summary
ORDER BY
    late_delivery_rate DESC,
    total_shipments DESC;