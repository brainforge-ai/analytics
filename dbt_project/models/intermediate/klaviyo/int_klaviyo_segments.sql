WITH raw AS (
  SELECT *
  FROM {{ ref('raw_klaviyo_segments') }}
),

flattened_conditions AS (
  SELECT
    r.segment_id,
    c.value:type AS condition_type, -- Extract the condition type (e.g., 'profile-metric', 'purchase', 'profile-attribute')
    c.value:attribute AS attribute  -- Extract the specific attribute being filtered on (e.g., 'city', 'email', etc.)
  FROM raw as r,
       LATERAL FLATTEN(r.condition_groups_raw) g,  -- Step 1: Flatten the array of condition groups in the JSON
       LATERAL FLATTEN(g.value:conditions) c       -- Step 2: Within each group, flatten the array of conditions
)

SELECT
  r.*,

  -- Complexity metric: total number of condition groups defined for this segment
  ARRAY_SIZE(r.condition_groups_raw) AS condition_group_count,

  -- Flag: TRUE if the segment logic includes profile metric or purchase-based conditions
  MAX(CASE WHEN fc.condition_type IN ('profile-metric', 'purchase') THEN TRUE ELSE FALSE END) AS has_purchase_conditions,
  
  -- Flag: TRUE if the segment filters on geographic location (e.g. attribute = 'city')
  MAX(CASE WHEN fc.condition_type = 'profile-attribute' AND fc.attribute = 'city' THEN TRUE ELSE FALSE END) AS has_geo_filters

FROM raw r
LEFT JOIN flattened_conditions fc
  ON r.segment_id = fc.segment_id
GROUP BY 
  r.segment_id,
  r.segment_name,
  r.created_at,
  r.updated_at,
  r.is_active,
  r.is_starred,
  r.condition_groups_raw