-- Potential API endpoint: https://developers.klaviyo.com/en/reference/profiles_api_overview

SELECT
    -- Core identifiers
    ID AS profile_id,
    
    -- Basic profile info
    ATTRIBUTES:email::STRING AS email,
    ATTRIBUTES:phone_number::STRING AS phone_number,
    ATTRIBUTES:external_id::STRING AS external_id,
    
    -- Personal details
    ATTRIBUTES:first_name::STRING AS first_name,
    ATTRIBUTES:last_name::STRING AS last_name,
    ATTRIBUTES:organization::STRING AS organization,
    ATTRIBUTES:title::STRING AS job_title,
    
    -- Location data
    ATTRIBUTES:location:address1::STRING AS address1,
    ATTRIBUTES:location:address2::STRING AS address2,
    ATTRIBUTES:location:city::STRING AS city,
    ATTRIBUTES:location:country::STRING AS country,
    ATTRIBUTES:location:region::STRING AS region,
    ATTRIBUTES:location:zip::STRING AS zip,
    
    -- Timestamps
    ATTRIBUTES:created::TIMESTAMP AS created_at,
    ATTRIBUTES:updated::TIMESTAMP AS updated_at,
    ATTRIBUTES:last_event_date::TIMESTAMP AS last_event_at, -- a timestamp representing when a profile was last active
    
    -- Consent and subscriptions - Subscription status
    ATTRIBUTES:subscriptions:email:marketing:consent::STRING AS email_consent_status, -- 'SUBSCRIBED'/'UNSUBSCRIBED'
    ATTRIBUTES:subscriptions:email:marketing:consent_timestamp::TIMESTAMP AS email_consent_changed_at,
    ATTRIBUTES:subscriptions:sms:marketing:consent::STRING AS sms_consent_status,
    ATTRIBUTES:subscriptions:sms:marketing:consent_timestamp::TIMESTAMP AS sms_consent_changed_at,
    
    -- Raw properties JSON
    ATTRIBUTES:properties::VARIANT AS raw_properties,

    -- 2. ORDER ATTRIBUTES (Links emails to conversions)
    ATTRIBUTES:predictive_analytics:historic_number_of_orders::INT AS lifetime_orders,
    ATTRIBUTES:predictive_analytics:total_clv::FLOAT AS customer_lifetime_value
        
FROM {{ source('portable_klaviyo', 'profiles') }}
    
