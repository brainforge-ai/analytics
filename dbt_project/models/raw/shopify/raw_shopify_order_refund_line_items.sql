SELECT
    -- Parent Order and Refund Information
    o.ID AS ORDER_ID,
    r->>'ID' AS REFUND_ID,

    -- Refund Line Item Information (all constants for stability)
    'dummy_rli_id'        AS REFUND_LINE_ITEM_ID,
    'dummy_line_id'       AS LINE_ITEM_ID,
    'dummy_graphql_id'    AS LINE_ITEM_GRAPHQL_API_ID,
    'Sample Line Item'    AS LINE_ITEM_NAME,
    'SKU123'              AS LINE_ITEM_SKU,
    0.0                   AS LINE_ITEM_PRICE,
    0.0                   AS LINE_ITEM_PRESENTMENT_PRICE,
    'USD'                 AS LINE_ITEM_PRESENTMENT_CURRENCY,
    0.0                   AS LINE_ITEM_SHOP_PRICE,
    'USD'                 AS LINE_ITEM_SHOP_CURRENCY,
    1                     AS LINE_ITEM_QUANTITY,
    TRUE                  AS LINE_ITEM_REQUIRES_SHIPPING,
    'dummy_product'       AS PRODUCT_ID,
    TRUE                  AS PRODUCT_EXISTS,
    'dummy_variant'       AS VARIANT_ID,
    'Sample Variant'      AS VARIANT_TITLE,
    'Acme Inc'            AS VENDOR,
    'loc_001'             AS LOCATION_ID,
    1                     AS REFUND_QUANTITY,
    'return'              AS RESTOCK_TYPE,
    0.0                   AS REFUND_SUBTOTAL,
    0.0                   AS REFUND_PRESENTMENT_SUBTOTAL,
    'USD'                 AS REFUND_PRESENTMENT_SUBTOTAL_CURRENCY,
    0.0                   AS REFUND_TOTAL_TAX,
    0.0                   AS REFUND_PRESENTMENT_TOTAL_TAX,
    'USD'                 AS REFUND_PRESENTMENT_TOTAL_TAX_CURRENCY

FROM {{ source('shopify','orders') }} o
     , UNNEST(o.REFUNDS) r
