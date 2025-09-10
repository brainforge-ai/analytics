-- Potential API endpoint: https://developers.klaviyo.com/en/reference/metrics_api_overview

SELECT
    -- Core identifiers
    ID AS metric_id,
    
    -- Metric metadata
    ATTRIBUTES:name::STRING AS metric_name,
    ATTRIBUTES:created::TIMESTAMP AS created_at,
    ATTRIBUTES:updated::TIMESTAMP AS updated_at,
    
    -- Integration info (source system)
    ATTRIBUTES:integration:id::STRING AS integration_id,
    ATTRIBUTES:integration:key::STRING AS integration_key,
    ATTRIBUTES:integration:name::STRING AS integration_name,
    ATTRIBUTES:integration:object::STRING AS integration_object,
    ATTRIBUTES:integration:category::STRING AS integration_category,

    -- Integration info (simplified)
    CASE 
        WHEN ATTRIBUTES:integration:category::STRING LIKE '%eCommerce%' THEN 'ecommerce'
        WHEN ATTRIBUTES:integration:category::STRING LIKE '%Rewards%' THEN 'rewards'
        WHEN ATTRIBUTES:integration:category::STRING LIKE '%Subscriptions%' THEN 'subscriptions'
        ELSE LOWER(ATTRIBUTES:integration:category::STRING)
    END AS integration_category_simplified,
    
    -- Metric classification flags
    CASE 
        -- Email metrics (expanded list)
        WHEN ATTRIBUTES:name IN ('Received Email', 'Opened Email', 'Clicked Email', 
                               'Bounced Email', 'Dropped Email', 'Unsubscribed Email',
                               'Marked Email as Spam', 'Delivered Email') THEN 'email'
        -- SMS metrics
        WHEN ATTRIBUTES:name ILIKE '%sms%' OR ATTRIBUTES:name ILIKE '%text%' THEN 'sms'
        -- Order metrics (expanded list)
        WHEN ATTRIBUTES:name IN ('Placed Order', 'Ordered Product', 'Ordered Offer',
                               'Started Checkout', 'Completed Payment', 'Fulfilled Order') THEN 'order'
        -- Form submissions
        WHEN ATTRIBUTES:name IN ('Submitted Form', 'Filled Out Form', 'CompleteRegistration') THEN 'form'
        -- Rewards/loyalty
        WHEN ATTRIBUTES:name ILIKE '%socialsnowball%' OR ATTRIBUTES:integration:name = 'Social Snowball' THEN 'rewards'
        -- API events
        WHEN ATTRIBUTES:integration:category = 'API' THEN 'api'
        -- Fallback categories
        WHEN ATTRIBUTES:integration:category = 'eCommerce' THEN 'ecommerce'
        WHEN ATTRIBUTES:integration:category = 'Advertising' THEN 'advertising'
        ELSE 'other'
    END AS metric_category,
    
    -- Email-specific flags
    CASE 
        WHEN metric_category = 'email' THEN TRUE
        WHEN ATTRIBUTES:name IN ('Email Signup', 'Email Subscription') THEN TRUE
        ELSE FALSE
    END AS is_email_metric, --  identifies all email-related events
    
    -- Conversion flags
    CASE 
        WHEN metric_category IN ('order', 'form') THEN TRUE
        WHEN ATTRIBUTES:name IN ('Completed Purchase', 'Converted Offer',
                               'Redeemed Coupon', 'Claimed Discount') THEN TRUE
        ELSE FALSE
    END AS is_conversion_metric, -- flags order-related events
    
    -- Raw data for reference
    ATTRIBUTES AS attributes_column_raw,
    RELATIONSHIPS AS relationships_column_raw
    
FROM {{ source('portable_klaviyo', 'metrics') }}

