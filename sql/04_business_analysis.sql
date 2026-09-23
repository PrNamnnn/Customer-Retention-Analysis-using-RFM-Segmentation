-- ============================================================
-- Business Analysis Queries
-- Customer Retention & RFM Segmentation
-- ============================================================


-- 1. Revenue Contribution by Customer Segment
-- ============================================================

SELECT
    Segment,
    COUNT(*) AS customer_count,
    SUM(Monetary) AS total_revenue,
    AVG(Monetary) AS avg_monetary,
    AVG(Frequency) AS avg_frequency,
    AVG(Recency) AS avg_recency

FROM customer_rfm

GROUP BY Segment

ORDER BY total_revenue DESC;


-- 2. Monthly Revenue Trend
-- ============================================================

SELECT
    DATEFROMPARTS(
        YEAR(order_purchase_timestamp),
        MONTH(order_purchase_timestamp),
        1
    ) AS purchase_month,

    SUM(total_payment) AS monthly_revenue

FROM master_df

WHERE order_status = 'delivered'

GROUP BY
    YEAR(order_purchase_timestamp),
    MONTH(order_purchase_timestamp)

ORDER BY purchase_month;


-- 3. Product Category Revenue
-- ============================================================

SELECT
    p.product_category_name,
    SUM(i.price) AS total_revenue

FROM order_items i

INNER JOIN products p
    ON i.product_id = p.product_id

GROUP BY
    p.product_category_name

ORDER BY
    total_revenue DESC;


-- 4. Payment Method Distribution
-- ============================================================

SELECT
    payment_type,
    COUNT(*) AS payment_count,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS payment_percentage

FROM payments

GROUP BY payment_type

ORDER BY payment_count DESC;


-- 5. Repeat Customer Analysis by Payment Type
-- ============================================================

SELECT
    payment_type,

    COUNT(DISTINCT customer_unique_id) AS total_customers,

    COUNT(DISTINCT CASE
        WHEN Repeat_Status = 'Repeat'
        THEN customer_unique_id
    END) AS repeat_customers,

    ROUND(
        100.0 *
        COUNT(DISTINCT CASE
            WHEN Repeat_Status = 'Repeat'
            THEN customer_unique_id
        END)
        / COUNT(DISTINCT customer_unique_id),
        2
    ) AS repeat_rate

FROM customer_payment_analysis

GROUP BY payment_type

ORDER BY repeat_rate DESC;