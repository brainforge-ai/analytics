SELECT
    ID::STRING AS CUSTOMER_ID, -- Order ID from the orders table
    tag AS TAG -- Flattened tag value
FROM {{ source('shopify','customers') }} c
     , UNNEST(STRING_SPLIT(c.TAGS, ', ')) AS tag
WHERE c.TAGS IS NOT NULL