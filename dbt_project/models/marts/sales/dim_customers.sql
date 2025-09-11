
WITH 
shopify_customers AS (
    SELECT 
        distinct
        c.customer_id::string as customer_id,
        'Shopify' as platform_source,
        c.email,
        c.full_name,
        c.phone,
        c.address_1,
        c.address_2,
        c.city,
        c.province as state,
        c.province_code as state_code,
        c.country,
        c.country_code,
        c.zip,
        c.zip_cleaned,
        c.full_address,
        c.lifetime_orders,
        '2025-01-01' as first_order_date,
        '2025-01-01' as latest_order_date,
        c.past_subscriber_bool,
        c.active_subscriber_bool,
        c.total_spent,
        c.email_marketing_sku,
        c.email_marketing_level,
        c.email_marketing_sub_date
    FROM {{ ref('int_shopify_customer') }} c
 
),

-- Get subscription details from Shopify orders
subscription_details AS (
    SELECT 
        customer_id::string as customer_id,
        MAX(CASE WHEN is_subscription_order = TRUE THEN created_at END) as latest_subscription_start_date,
        MAX(CASE WHEN is_subscription_order = TRUE AND cancelled_at IS NOT NULL THEN cancelled_at END) as latest_subscription_cancel_date,
        COUNT(DISTINCT CASE WHEN is_subscription_order = TRUE THEN order_id END) as total_subscription_orders,
        SUM(CASE WHEN is_subscription_recurring_order = TRUE THEN 1 ELSE 0 END) as total_recurring_orders
    FROM {{ ref('int_shopify_order') }}
    GROUP BY 1
),

-- Combine all customers
combined_customers AS (
    SELECT * FROM shopify_customers
),

final AS (
    SELECT 
        c.customer_id,
        c.platform_source,
        c.email,
        c.full_name,
        c.phone,
        c.address_1,
        c.address_2,
        c.city,
        c.state,
        c.state_code,
        c.country,
        c.country_code,
        c.zip,
        c.zip_cleaned,
        c.full_address,
        c.lifetime_orders,
        c.first_order_date,
        c.latest_order_date,
        c.past_subscriber_bool,
        c.active_subscriber_bool,
        c.total_spent,
        c.email_marketing_sku,
        c.email_marketing_level,
        c.email_marketing_sub_date,
        s.latest_subscription_start_date,
        s.latest_subscription_cancel_date,
        s.total_subscription_orders,
        s.total_recurring_orders,
        
        -- Derived fields
        100 as customer_lifetime_days,
        CASE 
            WHEN c.active_subscriber_bool = TRUE THEN 'ACTIVE'
            WHEN c.past_subscriber_bool = TRUE THEN 'CHURNED'
            WHEN s.total_subscription_orders > 0 THEN 'CHURNED'
            ELSE 'NEVER_SUBSCRIBED'
        END as subscription_status,
        
        -- Customer value metrics
        COALESCE(c.total_spent, 0) / NULLIF(c.lifetime_orders, 0) as avg_order_value,
        True as is_active_last_12m,
        
        -- Additional flags
        CASE 
            WHEN c.lifetime_orders > 1 THEN TRUE 
            ELSE FALSE 
        END as is_repeat_customer,
        
        
    FROM combined_customers c
    LEFT JOIN subscription_details s
        ON s.customer_id = c.customer_id
)

SELECT * from final