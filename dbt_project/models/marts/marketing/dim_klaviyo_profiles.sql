select
    -- Core identifiers
    profile_id,
    
    -- Basic profile info
    email,
    phone_number,
    external_id,
    
    -- Personal details
    first_name,
    last_name,
    organization,
    job_title,
    
    -- Location data
    address1,
    address2,
    city,
    country,
    region,
    zip,
    
    -- Timestamps
    created_at,
    updated_at,
    last_event_at,
    
    -- Consent and subscriptions
    email_consent_status,
    email_consent_changed_at,
    sms_consent_status,
    sms_consent_changed_at,
    
    -- Raw properties (as JSON)
    raw_properties,

    -- Order attributes
    lifetime_orders,
    customer_lifetime_value
    
from {{ ref('raw_klaviyo_profiles') }}