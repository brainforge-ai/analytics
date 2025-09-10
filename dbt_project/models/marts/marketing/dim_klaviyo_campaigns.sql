
select
    -- Core identifiers
    campaign_id,
        
    -- Campaign metadata
    campaign_name,
    send_time,
    created_at,
    updated_at,
    campaign_status,
    is_archived,
    
    -- Audience segments
    included_segment_ids,
    excluded_segment_ids,
    
    -- Tracking options
    -- Email and SMS
    is_add_utm,
    utm_params,
    -- Email only
    tracks_clicks,
    tracks_opens,
    
    -- Relationships column (contains the messages associated with the campaign)
    campaign_message_ids
from {{ ref ('raw_klaviyo_campaigns') }}