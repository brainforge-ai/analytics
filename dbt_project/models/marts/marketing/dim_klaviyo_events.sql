SELECT
    -- Core Event Identifiers
    event_id,
    profile_id,
    metric_id,
    
    -- Event Timing (Multiple Formats)
    event_datetime,
    event_timestamp,
    event_timestamp_unix,
    
    -- Campaign/Message Tracking
    message_id,
    campaign_name,
    is_from_flow,
    flow_id,
    
    -- Email Engagement Details
    recipient_email,
    email_subject,
    CASE 
        WHEN campaign_name IS NOT NULL THEN 'Campaign'
        WHEN is_from_flow THEN 'Automation Flow'
        ELSE 'Other'
    END AS message_type,
    
    -- Technical Email Properties
    sending_domain,
    email_domain,
    inbox_provider,
    user_agent,
    is_machine_open,
    
    -- Derived Engagement Quality Flags
    CASE WHEN is_machine_open THEN 'Machine' ELSE 'Human' END AS open_agent_type,
        CASE 
        WHEN inbox_provider IN ('Gmail', 'Hotmail / Outlook', 'Office 365', 'Yahoo', 'GMX', 'Mail.ru', 'Web.de', 'Protonmail') THEN 'Major Provider'
        WHEN inbox_provider = 'Apple' OR inbox_provider = 'Apple Private Email Relay' THEN 'Apple Mail'
        WHEN inbox_provider IN ('Verizon Media Group', 'Comcast', 'Charter Communications', 'CenturyLink', 'Windstream Communications', 'Sasktel', 'Videotron', 'BTInternet', 'Virgin Media', 'Bell Canada') THEN 'ISP'
        WHEN inbox_provider IN ('Gsuite', 'Zoho', 'Amazon SES Inbound', 'Rackspace', 'Proofpoint', 'Barracuda Networks', 'Mimecast', 'Cisco Ironport Hosted Email Security', 'Spam Experts', 'Sophos', 'Trendmicro') THEN 'Business/Enterprise'
        WHEN inbox_provider IN ('Naver', 'QQ', 'Netease', 'Seznam', 'ABV.bg', 'Yandex', 'Libero', 'Wirtualna Polska', 'onet', 'La Poste', 'Free.fr', 'Freenet.de', 'Orange.fr', 'SFR', 'T-online', 'Bluewin') THEN 'Regional Provider'
        WHEN inbox_provider IN ('PenTeleData', 'GoDaddy', 'SiteGround', 'Namecheap', 'Arcor', 'United Online', '1&1', 'One.com', 'Ionos', 'Strato AG', 'Above.com', 'CarrierZone', 'Fastmail', 'Mail.com', 'Spark XTRA Mail') THEN 'Other Provider'
        WHEN inbox_provider = 'VadeSecure' OR inbox_provider = 'MailChannels' THEN 'Security/Filtering'
        WHEN inbox_provider IS NULL THEN 'Unknown'
        ELSE 'Other'
    END AS inbox_category,
    
    -- Cohort Information
    send_cohort_id,
    cohort_handoff_time,
    cohort_message_id,
    
    -- Event Value
    event_value,
    
    -- Raw Data (Preserved)
    event_properties_json_from_attributes_raw,
    attributes_column_raw,
    relationships_column_raw

FROM {{ ref('raw_klaviyo_events') }}