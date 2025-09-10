(WITH first_order AS (
    SELECT
        customer_id,
        app_source,
        MIN(date(created_at)) AS first_order_date
    FROM {{ ref('fact_orders') }}
    GROUP BY customer_id, app_source
),
cohort_customer_count AS (
    select 
        DATE_TRUNC('month', f.first_order_date) AS cohort_month, 
        app_source,
        count(distinct customer_id) as distinct_customers
    from first_order f
    group by 1,2
),
orders_with_cohort AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.app_source,
        DATE_TRUNC('month', f.first_order_date) AS cohort_month,
        DATE_TRUNC('month', date(o.created_at)) AS order_month,
        DATEDIFF(MONTH, DATE_TRUNC('month', f.first_order_date), DATE_TRUNC('month', date(o.created_at))) AS months_since_first_order,
        o.total_line_items_price - o.total_discounts + o.shipping_price_final AS sales_revenue,
        o.cogs_product_cost + o.order_shipping_cost + o.order_box_cost + o.order_pick_cost + o.platform_fee + o.processing_fee AS fully_loaded_cogs,
        (o.total_line_items_price - o.total_discounts + o.shipping_price_final) -
        (o.cogs_product_cost + o.order_shipping_cost + o.order_box_cost + o.order_pick_cost + o.platform_fee + o.processing_fee) AS gross_profit,
        CASE
            WHEN date(o.created_at) = f.first_order_date THEN 1 ELSE 0
        END AS is_first_order
    FROM {{ ref('fact_orders') }} o
    INNER JOIN first_order f
    ON o.customer_id = f.customer_id
    AND o.app_source = f.app_source
)
,
aggregated as (
    SELECT
        cohort_month,
        app_source,
        CASE
            WHEN is_first_order = 1 THEN -1
            ELSE months_since_first_order
        END AS months_since_first_order,
        SUM(gross_profit) AS gross_profit,
        SUM(sales_revenue) AS sales_revenue,
        SUM(fully_loaded_cogs) AS fully_loaded_cogs
    FROM orders_with_cohort
    GROUP BY 1,2,3
),
aggregated_joined_customers AS (
    select a.*, c.distinct_customers
    from aggregated a inner join cohort_customer_count c using (cohort_month, app_source)
),
cumulative AS (
    SELECT
        cohort_month,
        app_source,
        months_since_first_order,
        distinct_customers,
        gross_profit,
        SUM(gross_profit) OVER (
            PARTITION BY cohort_month, app_source
            ORDER BY months_since_first_order
        ) AS cumulative_gross_profit,

        sales_revenue,
        SUM(sales_revenue) OVER (
            PARTITION BY cohort_month, app_source
            ORDER BY months_since_first_order
        ) AS cumulative_sales_revenue,

        fully_loaded_cogs,
        SUM(fully_loaded_cogs) OVER (
            PARTITION BY cohort_month, app_source
            ORDER BY months_since_first_order
        ) AS cumulative_fully_loaded_cogs,

         CASE
            WHEN SUM(sales_revenue) OVER (
                PARTITION BY cohort_month, app_source
                ORDER BY months_since_first_order
            ) > 0 THEN
                100.0 * SUM(gross_profit) OVER (
                    PARTITION BY cohort_month, app_source
                    ORDER BY months_since_first_order
                ) / SUM(sales_revenue) OVER (
                    PARTITION BY cohort_month, app_source
                    ORDER BY months_since_first_order
                )
            ELSE 0
        END AS cumulative_gross_margin_percentage

    FROM aggregated_joined_customers
)
select
    *,
    case
        when months_since_first_order = -1 then 'first_order'
        else months_since_first_order::string
    end as months_since_first_order_label
from cumulative
)

union all

(
WITH first_order AS (
    SELECT
        customer_id,
        MIN(date(created_at)) AS first_order_date
    FROM {{ ref('fact_orders') }}
    GROUP BY customer_id
),
cohort_customer_count AS (
    select 
        DATE_TRUNC('month', f.first_order_date) AS cohort_month, 
        count(distinct customer_id) as distinct_customers
    from first_order f
    group by 1
),
orders_with_cohort AS (
    SELECT
        o.order_id,
        o.customer_id,
        DATE_TRUNC('month', f.first_order_date) AS cohort_month,
        DATE_TRUNC('month', date(o.created_at)) AS order_month,
        DATEDIFF(MONTH, DATE_TRUNC('month', f.first_order_date), DATE_TRUNC('month', date(o.created_at))) AS months_since_first_order,
        o.total_line_items_price - o.total_discounts + o.shipping_price_final AS sales_revenue,
        o.cogs_product_cost + o.order_shipping_cost + o.order_box_cost + o.order_pick_cost + o.platform_fee + o.processing_fee AS fully_loaded_cogs,
        (o.total_line_items_price - o.total_discounts + o.shipping_price_final) -
        (o.cogs_product_cost + o.order_shipping_cost + o.order_box_cost + o.order_pick_cost + o.platform_fee + o.processing_fee) AS gross_profit,
        CASE
            WHEN date(o.created_at) = f.first_order_date THEN 1 ELSE 0
        END AS is_first_order
    FROM {{ ref('fact_orders') }} o
    INNER JOIN first_order f ON o.customer_id = f.customer_id
)
,
aggregated as (
    SELECT
        cohort_month,
        CASE
            WHEN is_first_order = 1 THEN -1
            ELSE months_since_first_order
        END AS months_since_first_order,
        SUM(gross_profit) AS gross_profit,
        SUM(sales_revenue) AS sales_revenue,
        SUM(fully_loaded_cogs) AS fully_loaded_cogs
    FROM orders_with_cohort
    GROUP BY 1,2
),
aggregated_joined_customers AS (
    select a.*, c.distinct_customers
    from aggregated a inner join cohort_customer_count c using (cohort_month)
),
cumulative AS (
    SELECT
        cohort_month,
        'All' as app_source,
        months_since_first_order,
        distinct_customers,
        gross_profit,
        SUM(gross_profit) OVER (
            PARTITION BY cohort_month
            ORDER BY months_since_first_order
        ) AS cumulative_gross_profit,

        sales_revenue,
        SUM(sales_revenue) OVER (
            PARTITION BY cohort_month
            ORDER BY months_since_first_order
        ) AS cumulative_sales_revenue,

        fully_loaded_cogs,
        SUM(fully_loaded_cogs) OVER (
            PARTITION BY cohort_month
            ORDER BY months_since_first_order
        ) AS cumulative_fully_loaded_cogs,

         CASE
            WHEN SUM(sales_revenue) OVER (
                PARTITION BY cohort_month
                ORDER BY months_since_first_order
            ) > 0 THEN
                100.0 * SUM(gross_profit) OVER (
                    PARTITION BY cohort_month
                    ORDER BY months_since_first_order
                ) / SUM(sales_revenue) OVER (
                    PARTITION BY cohort_month
                    ORDER BY months_since_first_order
                )
            ELSE 0
        END AS cumulative_gross_margin_percentage

    FROM aggregated_joined_customers
)
select
    *,
    case
        when months_since_first_order = -1 then 'first_order'
        else months_since_first_order::string
    end as months_since_first_order_label
from cumulative
)
