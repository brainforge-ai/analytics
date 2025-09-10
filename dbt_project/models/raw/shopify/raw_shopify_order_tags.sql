SELECT
    ID AS ORDER_ID, -- Order ID from the orders table
    cast(tag as string) AS TAG -- Flattened tag value
FROM {{ source('shopify','orders') }} o
     , UNNEST(STRING_SPLIT(o.TAGS, ', ')) AS tag
WHERE o.TAGS IS NOT NULL