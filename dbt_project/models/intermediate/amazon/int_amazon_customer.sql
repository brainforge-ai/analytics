with customers as (
    select 
        *
        FROM {{ ref('int_amazon_order')}}
        QUALIFY row_number() over(partition by customer_id order by CREATED_DATE desc) = 1
), customer_agg as (
    select 
        customer_id,
        count(distinct seller_order_id) as lifetime_orders,
        min(CREATED_DATE) as first_order_date,
        max(CREATED_DATE) as most_recent_order_date
    FROM {{ ref('int_amazon_order')}}
    GROUP BY customer_id
)
SELECT
    customer_id,
    'Amazon' AS platform_source,
    buyer_info_buyer_email AS email,
    initcap(trim(shipping_address_name)) as full_name,
    shipping_address_phone as phone,
    shipping_address_address_line_1 as address_1,
    shipping_address_address_line_2 as address_2,
    initcap(trim(SHIPPING_ADDRESS_CITY)) as city,
    SHIPPING_ADDRESS_STATE_OR_REGION as state,
    SHIPPING_ADDRESS_POSTAL_CODE as zip,
    SHIPPING_ADDRESS_COUNTRY_CODE as country_code,
    customer_agg.lifetime_orders,
    customer_agg.first_order_date,
    customer_agg.most_recent_order_date
FROM customers inner join customer_agg using (customer_id)
