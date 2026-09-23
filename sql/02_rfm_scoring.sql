-- RFM Quartile Scoring

SELECT
    customer_unique_id,
    recency,
    frequency,
    monetary,

    NTILE(4) OVER (
        ORDER BY recency DESC
    ) AS r_score,

    NTILE(4) OVER (
        ORDER BY frequency
    ) AS f_score,

    NTILE(4) OVER (
        ORDER BY monetary
    ) AS m_score

FROM customer_rfm;