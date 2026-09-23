-- ============================================================
-- Cohort & Customer Retention Analysis
-- ============================================================

-- 1. Identify each customer's first purchase month

WITH customer_first_purchase AS (

    SELECT
        customer_unique_id,
        MIN(order_purchase_timestamp) AS first_purchase_date
    FROM master_df
    WHERE order_status = 'delivered'
    GROUP BY customer_unique_id
),

-- 2. Assign each customer to a cohort month
customer_cohorts AS (

    SELECT
        customer_unique_id,
        DATEFROMPARTS(
            YEAR(first_purchase_date),
            MONTH(first_purchase_date),
            1
        ) AS cohort_month
    FROM customer_first_purchase
),

-- 3. Get every customer's purchase month

customer_purchases AS (

    SELECT DISTINCT
        m.customer_unique_id,

        DATEFROMPARTS(
            YEAR(m.order_purchase_timestamp),
            MONTH(m.order_purchase_timestamp),
            1
        ) AS purchase_month

    FROM master_df m

    WHERE m.order_status = 'delivered'
),

-- 4. Combine purchase month with cohort month

cohort_activity AS (

    SELECT
        p.customer_unique_id,
        c.cohort_month,
        p.purchase_month,

        DATEDIFF(
            MONTH,
            c.cohort_month,
            p.purchase_month
        ) AS cohort_index

    FROM customer_purchases p

    INNER JOIN customer_cohorts c
        ON p.customer_unique_id = c.customer_unique_id
)

-- 5. Count active customers for each cohort/month

SELECT
    cohort_month,
    cohort_index,
    COUNT(DISTINCT customer_unique_id) AS active_customers

FROM cohort_activity

GROUP BY
    cohort_month,
    cohort_index

ORDER BY
    cohort_month,
    cohort_index;

-- ============================================================
-- Cohort Retention Percentage
-- ============================================================

WITH cohort_counts AS (

    SELECT
        cohort_month,
        cohort_index,
        COUNT(DISTINCT customer_unique_id) AS active_customers

    FROM cohort_activity

    GROUP BY
        cohort_month,
        cohort_index
)

SELECT
    cohort_month,
    cohort_index,
    active_customers,

    ROUND(
        100.0 * active_customers
        / FIRST_VALUE(active_customers) OVER (
            PARTITION BY cohort_month
            ORDER BY cohort_index
        ),
        2
    ) AS retention_percentage

FROM cohort_counts

ORDER BY
    cohort_month,
    cohort_index;