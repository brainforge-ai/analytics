SELECT
    ID::STRING AS CUSTOMER_ID, -- Order ID from the orders table
    tag.VALUE::STRING AS TAG -- Flattened tag value
FROM {{ source('shopify','customers') }} ,
TABLE(FLATTEN(INPUT => SPLIT(TAGS, ', '))) tag -- Flatten the array of tags
WHERE TAGS IS NOT NULL