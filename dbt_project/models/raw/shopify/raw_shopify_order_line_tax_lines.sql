SELECT
    -- Order-level information
    o.ID AS ORDER_ID,                             -- Parent order ID

    li->>'ID'        AS LINE_ITEM_ID,             -- Line item ID

    -- Tax Lines
    'vat'     AS TAX_TITLE,
    CAST(12 AS DOUBLE) AS TAX_PRICE,
    CAST(0.05  AS DOUBLE) AS TAX_RATE,

    CAST(12 AS DOUBLE) AS TAX_PRESENTMENT_AMOUNT,
    'USD' AS TAX_PRESENTMENT_CURRENCY,

    CAST(12 AS DOUBLE) AS TAX_SHOP_AMOUNT,
    'USD' AS TAX_SHOP_CURRENCY

FROM {{ source('shopify','orders') }} o
     -- Flatten line items
     , UNNEST(o.LINE_ITEMS) AS li
     -- Flatten tax lines inside each line item
