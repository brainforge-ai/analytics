-- Potential API endpoint: https://developers.klaviyo.com/en/reference/events_api_overview

-- There are two types of endpoints within the Events API 
-- - Events endpoints for fetching or creating event data.
-- - Relationships endpoints for accessing a list of related metrics or profiles for a specific event.

SELECT
    -- Core identifiers
    ID AS event_id,
    TIMESTAMP AS event_timestamp,

    -- Event timing
    ATTRIBUTES:datetime::TIMESTAMP AS event_datetime,
    ATTRIBUTES:timestamp::TIMESTAMP AS event_timestamp_unix,
    -- ATTRIBUTES:uuid::STRING AS event_uuid, -- mainly for Klaviyo's internal tracking when receiving events

    -- Relationships
    RELATIONSHIPS:profile:data:id::STRING AS profile_id,
    RELATIONSHIPS:metric:data:id::STRING AS metric_id,
    
    -- Message/campaign tracking
    ATTRIBUTES:event_properties:"$message"::STRING AS message_id,  -- links events to specific campaigns
    ATTRIBUTES:event_properties:"$message_interaction"::STRING AS interaction_message_id,
    ATTRIBUTES:event_properties:"$flow"::STRING AS flow_id,
    ATTRIBUTES:event_properties:"Campaign Name"::STRING AS campaign_name,
    CASE 
        WHEN ATTRIBUTES:event_properties:"Campaign Name" LIKE 'Flow |%' THEN TRUE
        ELSE FALSE
    END AS is_from_flow,
    
    -- Email details
    ATTRIBUTES:event_properties:"Recipient Email Address"::STRING AS recipient_email, -- potential FK to Orders
    ATTRIBUTES:event_properties:"Email Domain"::STRING AS email_domain,
    ATTRIBUTES:event_properties:"Inbox Provider"::STRING AS inbox_provider,
    ATTRIBUTES:event_properties:"Subject"::STRING AS email_subject,
    
    -- Technical email properties
    ATTRIBUTES:event_properties:"$internal":"Sending Domain"::STRING AS sending_domain,
    ATTRIBUTES:event_properties:"$internal":"Preview Text"::STRING AS preview_text,
    ATTRIBUTES:event_properties:"$internal":"Transmission ID"::STRING AS transmission_id,
    ATTRIBUTES:event_properties:"$internal":"Sending Ip Address"::STRING AS sending_ip,
    ATTRIBUTES:event_properties:"$internal":"User Agent"::STRING AS user_agent,
    
    -- Engagement quality
    ATTRIBUTES:event_properties:"machine_open"::BOOLEAN AS is_machine_open,
    
    -- Cohort/group information
    ATTRIBUTES:event_properties:"$group_ids"::ARRAY AS group_ids,
    ATTRIBUTES:event_properties:"$_cohort$message_send_cohort"::STRING AS send_cohort_id,
    SPLIT_PART(ATTRIBUTES:event_properties:"$_cohort$message_send_cohort", ':', 1)::INTEGER AS cohort_handoff_time,
    SPLIT_PART(ATTRIBUTES:event_properties:"$_cohort$message_send_cohort", ':', 2)::STRING AS cohort_message_id,
    
    -- Event value tracking
    ATTRIBUTES:event_properties:"$value"::FLOAT AS event_value,
    ATTRIBUTES:event_properties:"$event_id"::STRING AS klaviyo_event_id,
    
    -- Raw properties for debugging
    ATTRIBUTES:event_properties AS event_properties_json_from_attributes_raw,
    ATTRIBUTES AS attributes_column_raw,
    RELATIONSHIPS AS relationships_column_raw
    
FROM {{ source('portable_klaviyo', 'events') }}

