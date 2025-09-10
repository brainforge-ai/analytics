-- Potential API endpoint: https://developers.klaviyo.com/en/reference/campaigns_api_overview

SELECT
    -- Core identifiers
    c.ID AS campaign_id,
    
    -- Campaign metadata
    c.ATTRIBUTES:name::STRING AS campaign_name,
    c.ATTRIBUTES:send_time::TIMESTAMP AS send_time,
    c.ATTRIBUTES:created_at::TIMESTAMP AS created_at,
    c.ATTRIBUTES:updated_at::TIMESTAMP AS updated_at,
    c.ATTRIBUTES:status::STRING AS campaign_status,
    c.ATTRIBUTES:archived::BOOLEAN AS is_archived,
    
    -- Audience segments
    c.ATTRIBUTES:audiences:included::ARRAY AS included_segment_ids,
    c.ATTRIBUTES:audiences:excluded::ARRAY AS excluded_segment_ids,
    
    -- Tracking options (tracking options shared by email and SMS campaigns)
    -- Email and SMS
    c.ATTRIBUTES:tracking_options:is_tracking_clicks::BOOLEAN AS is_add_utm,
    c.ATTRIBUTES:tracking_options:is_tracking_clicks::BOOLEAN AS utm_params,
    -- Email only
    c.ATTRIBUTES:tracking_options:is_tracking_clicks::BOOLEAN AS tracks_clicks,
    c.ATTRIBUTES:tracking_options:is_tracking_opens::BOOLEAN AS tracks_opens,
    
    -- Relationships column (contains the messages associated with the campaign)
    ARRAY_AGG(f.value:id::STRING) AS campaign_message_ids,
    
FROM {{ source('portable_klaviyo', 'campaigns') }} as c,
LATERAL FLATTEN(input => c.RELATIONSHIPS:"campaign-messages":"data", OUTER => TRUE) f
GROUP BY 
    c.ID,
    c.TYPE,
    c.ATTRIBUTES,
    c.RELATIONSHIPS
