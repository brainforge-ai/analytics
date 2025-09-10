SELECT
    -- Parent order-level information
    o.ID AS ORDER_ID, -- Parent order ID

    -- Discount Code-level information
    dc.VALUE:AMOUNT::FLOAT AS DISCOUNT_AMOUNT,
    dc.VALUE:CODE::STRING AS DISCOUNT_CODE,
    dc.VALUE:TYPE::STRING AS DISCOUNT_TYPE

FROM {{ source('portable_shopify','orders') }} o,
     TABLE(FLATTEN(INPUT => o.DISCOUNT_CODES)) dc
