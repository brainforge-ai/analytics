SELECT
    -- Core identifiers
    segment_id,
    
    -- Segment metadata
    segment_name,
    created_at,
    updated_at,
    is_active,
    is_starred,
    
    -- Condition groups (raw JSON) - directly from the `int_klaviyo_segments`
    condition_groups_raw,

    -- 1. Complexity metric: the number of condition groups (you might want this as a dimension or fact)
    condition_group_count,

    -- 2. Flags based on conditions
    has_purchase_conditions,
    has_geo_filters

FROM {{ ref('int_klaviyo_segments') }}