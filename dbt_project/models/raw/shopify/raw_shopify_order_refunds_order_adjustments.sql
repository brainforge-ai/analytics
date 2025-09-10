SELECT
    -- Parent order-level information
    o.ID AS ORDER_ID,

    -- Refund-level information
    r->>'ID' AS REFUND_ID,

    -- Order Adjustments (all constants)
    'dummy_adj_id'   AS ORDER_ADJUSTMENT_ID,
    0.0              AS ORDER_ADJUSTMENT_AMOUNT,
    'shipping_refund' AS ORDER_ADJUSTMENT_KIND,
    'Overcharge'     AS ORDER_ADJUSTMENT_REASON,
    0.0              AS ORDER_ADJUSTMENT_TAX_AMOUNT,
    0.0              AS ORDER_ADJUSTMENT_TAX_PRESENTMENT_AMOUNT,
    'USD'            AS ORDER_ADJUSTMENT_TAX_PRESENTMENT_CURRENCY,
    0.0              AS ORDER_ADJUSTMENT_TAX_SHOP_AMOUNT,
    'USD'            AS ORDER_ADJUSTMENT_TAX_SHOP_CURRENCY

FROM {{ source('shopify','orders') }} o,
     UNNEST(o.REFUNDS) r
