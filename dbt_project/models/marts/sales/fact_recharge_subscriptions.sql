with subscriptions as (
    select *
    from {{ ref('int_recharge__subscriptions') }}
),

customers as (
    select *
    from {{ ref('int_recharge__customers') }}
),

final as (
    select
        s.subscription_id,
        s.customer_id,
        c.email as customer_email,
        c.full_name as customer_full_name,
        s.created_at as subscription_start_date,
        s.cancelled_at,
        s.status as subscription_status,
        s.price as subscription_price,
        s.quantity,
        s.order_interval_frequency,
        s.order_interval_unit,
        s.charge_interval_frequency,
        s.cancellation_reason,
        ROW_NUMBER() OVER (PARTITION BY s.CUSTOMER_ID ORDER BY s.CREATED_AT) AS subscription_number,
        s.next_renewal_date,
        s.next_order_date,
        s.discount_code,
        s.discount_value_type,
        s.discount_value
    from subscriptions s
    left join customers c 
        on s.customer_id = c.customer_id
)

select 
    *
from final 