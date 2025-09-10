SELECT
    -- Core Metric Identifiers
    metric_id,
    metric_name,
    
    -- Timestamps
    created_at,
    updated_at,
    
    -- Integration Source Details (Preserved Exactly)
    integration_id,
    integration_key,
    integration_name,
    integration_object,
    integration_category,
    
    -- Simplified Classifications
    integration_category_simplified,
    metric_category,
    
    -- Business-Friendly Categorization
    CASE
        WHEN metric_category = 'email' THEN 'Email'
        WHEN metric_category = 'sms' THEN 'SMS'
        WHEN metric_category = 'order' THEN 'Order'
        WHEN metric_category = 'form' THEN 'Form'
        WHEN metric_category = 'rewards' THEN 'Rewards'
        WHEN metric_category = 'api' THEN 'API'
        ELSE 'Other'
    END AS metric_type,
    
    -- Clear Boolean Flags
    is_email_metric,
    is_conversion_metric,
    
    -- Channel Classification
    CASE
        WHEN is_email_metric THEN 'Email Marketing'
        WHEN metric_category = 'sms' THEN 'SMS Marketing'
        WHEN is_conversion_metric THEN 'Conversion'
        ELSE 'Other'
    END AS channel_group,
    
    -- Raw Data Preservation
    attributes_column_raw,
    relationships_column_raw

from {{ ref('raw_klaviyo_metrics') }}