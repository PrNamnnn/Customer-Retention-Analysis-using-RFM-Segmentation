-- Customer-Level RFM Metrics

SELECT
    customer_unique_id,

    DATEDIFF(
        DAY,
        MAX(order_purchase_timestamp),
        (SELECT MAX(order_purchase_timestamp)
         FROM master_df)
    ) AS recency,

    COUNT(DISTINCT order_id) AS frequency,

    SUM(total_payment) AS monetary

FROM master_df

WHERE order_status = 'delivered'

GROUP BY customer_unique_id;