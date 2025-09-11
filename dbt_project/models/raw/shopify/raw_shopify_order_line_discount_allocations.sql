SELECT
    -- Order-level information
    o.ID AS ORDER_ID,                  -- Parent order ID

    -- Line-item-level information
    li->>'ID' AS LINE_ITEM_ID,         -- Line item ID

    -- Discount Allocations (dummy fields here)
    1     AS DISCOUNT_AMOUNT,
    0     AS DISCOUNT_APPLICATION_INDEX,
    '12'  AS DISCOUNT_PRESENTMENT_AMOUNT,
    'USD' AS DISCOUNT_PRESENTMENT_CURRENCY,
    '12'  AS DISCOUNT_SHOP_AMOUNT,
    'USD' AS DISCOUNT_SHOP_CURRENCY

FROM {{ source('shopify','orders') }} o
     -- Unnest line_items
     , UNNEST(o.LINE_ITEMS) li
     