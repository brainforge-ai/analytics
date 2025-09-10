
SELECT
    ORDER_ADJUSTMENT_ID,
    ORDER_ID,
    REFUND_ID,
    ORDER_ADJUSTMENT_AMOUNT,
    ORDER_ADJUSTMENT_TAX_AMOUNT,
    ORDER_ADJUSTMENT_KIND,
    ORDER_ADJUSTMENT_REASON
FROM {{ ref('raw_shopify_order_refunds_order_adjustments')}}--order_id level