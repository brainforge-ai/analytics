-- Potential API endpoint: https://developers.klaviyo.com/en/reference/lists_api_overview

SELECT
    -- Core identifiers
    ID AS list_id,

    -- List metadata
    ATTRIBUTES:name::STRING AS list_name,
    ATTRIBUTES:opt_in_process::STRING AS opt_in_process, --Whether the list uses single or double opt-in. Lists are set to double opt-in by default in all Klaviyo accounts
    ATTRIBUTES:created::TIMESTAMP AS created_at,
    ATTRIBUTES:updated::TIMESTAMP AS updated_at,

    -- Relationship links (for joining or lineage tracking)
    RELATIONSHIPS:profiles:links:related::STRING AS profiles_url,
    RELATIONSHIPS:"flow-triggers":links:related::STRING AS flow_triggers_url

FROM lists {{ source('portable_klaviyo', 'lists') }}

