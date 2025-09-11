
SELECT
    pv.PRODUCT_ID,
    pv.VARIANT_ID,
    pv.INVENTORY_ITEM_ID,
    pv.VARIANT_TITLE,
    pv.PRICE,
    -- ii.COST,
    pv.SKU,
    pv.COMPARE_AT_PRICE,
    pv.GRAMS,
    pv.INVENTORY_QUANTITY,
    pv.WEIGHT,
    pv.WEIGHT_UNIT,
    pv.CREATED_AT,
    pv.UPDATED_AT,
    pv.OPTION_1,
    pv.OPTION_2,
    pv.OPTION_3
FROM {{ ref('raw_shopify_product_variants')}} pv
