SELECT
    -- Parent order-level information
    o.ID AS ORDER_ID, -- Parent order ID

    -- Discount Code-level information
    dc->>'AMOUNT' AS DISCOUNT_AMOUNT,
    dc->>'CODE' AS DISCOUNT_CODE,
    dc->>'TYPE' AS DISCOUNT_TYPE

FROM {{ source('shopify','orders') }} o,
     UNNEST(o.DISCOUNT_CODES) AS dc
    