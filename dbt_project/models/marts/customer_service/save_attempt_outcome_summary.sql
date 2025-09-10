SELECT 
    distinct 
    t.ticket_id,
    t.created_datetime,
    t.closed_datetime,
    t.customer_email,
    REGEXP_SUBSTR(ARRAY_TO_STRING(t.macro_names, ','), 'Test Save Attempt[^,]+') AS save_attempt_name,
    TRIM(REGEXP_SUBSTR(
             REGEXP_SUBSTR(
                 ARRAY_TO_STRING(t.macro_names, ','), 
                                '(Test Save Attempt[^,]+)'), '[^-]+$')) as cancel_reason,
    o.customer_id as customer_id,
    o.order_id,
    o.order_created_at,
    o.order_status,
    s.subscription_id,
    s.cancelled_at,
    s.subscription_status,
    CASE
        WHEN s.cancelled_at IS NOT NULL
            --AND DATEDIFF(day, t.created_datetime, s.cancelled_at) <= 10
            AND s.cancelled_at > t.created_datetime
            AND DATEDIFF(day, t.created_datetime, s.cancelled_at) >= 0
        THEN DATEDIFF(day, t.created_datetime, s.cancelled_at)
        ELSE NULL
    END AS days_to_cancel,

    case 
        when s.cancelled_at IS NOT NULL and s.cancelled_at > t.created_datetime 
        then TRUE else FALSE 
    end as is_cancelled_sub,

    case when o.order_created_at > t.created_datetime then TRUE ELSE FALSE end as is_macro_saved_order,
    
    FROM {{ ref('fact_tickets') }} t
    LEFT JOIN {{ ref('dim_recharge_customers') }} c
        ON t.customer_email = c.email
    LEFT JOIN {{ ref('fact_recharge_orders') }} o
        ON c.customer_id = o.customer_id
    LEFT JOIN {{ ref('fact_recharge_subscriptions') }} s
        ON c.customer_id = s.customer_id

    WHERE ARRAY_TO_STRING(t.macro_names, ',') ILIKE '%Save Attempt%'
        AND LOWER(REGEXP_SUBSTR(ARRAY_TO_STRING(t.macro_names, ','), 'Test Save Attempt[^,]+')) NOT LIKE '%already canceled%' 
        AND LOWER(REGEXP_SUBSTR(ARRAY_TO_STRING(t.macro_names, ','), 'Test Save Attempt[^,]+')) NOT LIKE '%restart%'
