-- Potential API endpoint: https://developers.klaviyo.com/en/reference/segments_api_overview

SELECT
    -- Core identifiers
    ID AS segment_id,
    
    -- Segment metadata
    ATTRIBUTES:name::STRING AS segment_name,
    ATTRIBUTES:created::TIMESTAMP AS created_at,
    ATTRIBUTES:updated::TIMESTAMP AS updated_at,
    ATTRIBUTES:is_active::BOOLEAN AS is_active,
    ATTRIBUTES:is_starred::BOOLEAN AS is_starred,

    -- Condition groups
    -- This is a JSON object with complex logic. The API must be checked to understand it better.
    ATTRIBUTES:definition:condition_groups AS condition_groups_raw -- logic to explode it is complicated here

FROM {{ source('portable_klaviyo', 'segments') }}