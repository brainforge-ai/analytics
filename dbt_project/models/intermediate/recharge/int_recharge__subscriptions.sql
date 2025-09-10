WITH discounts AS (
    SELECT 
        customer:ID::INTEGER AS customer_id,
        discounts.value:CODE::STRING AS discount_code,
        discounts.value:VALUE::FLOAT AS discount_value,
        discounts.value:VALUE_TYPE::STRING AS discount_value_type
    FROM {{ source('portable_recharge', 'orders') }}, LATERAL FLATTEN(input => discounts) AS discounts
    QUALIFY ROW_NUMBER() OVER (PARTITION BY customer:ID::integer ORDER BY created_at) = 1
)
SELECT
    subscriptions.id AS subscription_id,
    subscriptions.customer_id,
    subscriptions.created_at,
    subscriptions.cancelled_at,
    subscriptions.status,
    subscriptions.price,
    subscriptions.quantity,
    subscriptions.charge_interval_frequency,
    subscriptions.order_interval_frequency,
    subscriptions.order_interval_unit,
    subscriptions.next_charge_scheduled_at as next_renewal_date,
    CASE 
        WHEN lower(subscriptions.status) = 'active' THEN
            CASE lower(subscriptions.order_interval_unit)
                WHEN 'day' THEN dateadd('day', subscriptions.order_interval_frequency::INTEGER, subscriptions.created_at)
                WHEN 'week' THEN dateadd('week', subscriptions.order_interval_frequency::INTEGER, subscriptions.created_at)
                WHEN 'month' THEN dateadd('month', subscriptions.order_interval_frequency::INTEGER, subscriptions.created_at)
                WHEN 'year' THEN dateadd('year', subscriptions.order_interval_frequency::INTEGER, subscriptions.created_at)
            END
        ELSE null
    END AS next_order_date,
    subscriptions.cancellation_reason,
    discounts.discount_code,
    discounts.discount_value,
    discounts.discount_value_type,
FROM {{ source('portable_recharge', 'subscriptions') }} 
LEFT JOIN discounts
USING (customer_id)
