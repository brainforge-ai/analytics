with shopify_order_calculated_fields as (
    select
        order_id,
        customer_type,
        is_refunded,
        IS_SUBSCRIPTION_RECURRING_ORDER,
        IS_SUBSCRIPTION_ORDER,
        is_recharge_order,
        IS_RENEWAL_ORDER,
        IS_REACTIVATION_ORDER,
        FIRST_TIME_CUSTOMER_ORDER,
        SUBSCRIPTION_FIRST_ORDER,
        IS_TIKTOK_SHOP,
        IS_KLAVIYO,
        IS_SNAPCHAT,
    from {{ref('int_shopify_order')}}
),

shopify_additional_details as(
    select
        order_id,
        offer as shopify_additional_details_offer,
        offer_name as shopify_additional_details_offer_name,
        sale_name as shopify_additional_details_sale_name
    from {{ref('int_shopify_order')}}
),

final as (
    SELECT
        'Amazon' AS app_source,
        ORDER_ITEM_ID AS ORDER_LINE_ID,
        AMAZON_ORDER_ID AS ORDER_ID,
        ASIN_ID AS PRODUCT_ID,
        order_created_date,
        NULL::string AS VARIANT_ID,
        PRODUCT_TITLE AS ORDER_LINE_NAME,
        PRODUCT_TITLE AS product_name,
        product_category,
        product_flavor,
        null as product_type,
        SELLER_SKU AS SKU,
        NULL AS FULFILLMENT_STATUS,
        QUANTITY_ORDERED AS QUANTITY,
        NULL AS GRAMS,
        NULL AS FULFILLABLE_QUANTITY,
        ITEM_PRICE_AMOUNT AS price,
        ITEM_PRICE_AMOUNT - ifnull(SHIPPING_PRICE_AMOUNT,0) - ifnull(SHIPPING_DISCOUNT_TAX_AMOUNT,0) - ifnull(ITEM_TAX_AMOUNT,0) - ifnull(PROMOTION_DISCOUNT_AMOUNT,0) - ifnull(PROMOTION_DISCOUNT_TAX_AMOUNT,0) as PRE_TAX_PRICE,
        ifnull(SHIPPING_DISCOUNT_TAX_AMOUNT,0) + ifnull(PROMOTION_DISCOUNT_AMOUNT,0) as total_discount,
        ITEM_TAX_AMOUNT as tax_amount,
        null::int as tax_rate,
        '' as tax_sku,
        null::int as order_refunded,
        null::int as quantity_refunded,
        null::int as refund_subtotal,
        null::int as refund_tax,

        -- New COGS fields (per unit)
        product_cost as cogs_unit_product_cost,
        unit_pick_cost as cogs_unit_pick_cost,
        unit_platform_fees as cogs_unit_platform_fees,

        -- Total COGS fields (multiplied by quantity)
        product_cost as cogs_total_product_cost,
        total_pick_cost as cogs_total_pick_cost,
        total_platform_fees as cogs_total_platform_fees,

        null as customer_type,
        null as is_refunded,
        null as IS_SUBSCRIPTION_RECURRING_ORDER,
        null as IS_SUBSCRIPTION_ORDER,
        null as is_recharge_order,
        null as IS_RENEWAL_ORDER,
        null as IS_REACTIVATION_ORDER,
        null as FIRST_TIME_CUSTOMER_ORDER,
        null as SUBSCRIPTION_FIRST_ORDER,
        null as IS_TIKTOK_SHOP,
        null as IS_KLAVIYO,
        null as IS_SNAPCHAT,
        null as shopify_additional_details_offer,
        null as shopify_additional_details_offer_name,
        null as shopify_additional_details_sale_name,

        -- Supporting fields for COGS calculations
        product_weight_pounds,
        packout_units,
        IS_SUBSCRIBE_AND_SAVE
    from {{ ref('int_amazon_order_line') }}

    union all

    SELECT 
        ol.app_source,
        ol.ORDER_LINE_ID::string AS order_line_id,
        ol.ORDER_ID::string as order_id,
        ol.PRODUCT_ID::string as product_id,
        ol.order_created_date,
        ol.VARIANT_ID,
        ol.ORDER_LINE_NAME,
        ol.product_name,
        ol.product_category,
        ol.product_flavor,
        ol.product_type,
        ol.SKU,
        ol.FULFILLMENT_STATUS,
        ol.ITEM_QUANTITY as QUANTITY,
        ol.GRAMS,
        ol.FULFILLABLE_QUANTITY,
        ol.PRE_TAX_PRICE,
        ol.PRICE,
        ol.TOTAL_DISCOUNT,
        ol.TAX_AMOUNT,
        ol.TAX_RATE,
        ol.TAX_SKU,
        ol.ORDER_REFUNDED,
        ol.quantity_refunded,
        ol.refund_subtotal,
        ol.refund_tax,

        -- New COGS fields (per unit)
        ol.unit_product_cost as cogs_unit_product_cost,
        ol.unit_pick_cost as cogs_unit_pick_cost,
        ol.unit_platform_fees as cogs_unit_platform_fees,

        -- Total COGS fields (multiplied by quantity)
        ol.cogs_product_cost as cogs_total_product_cost,
        ol.total_pick_cost as cogs_total_pick_cost,
        ol.total_platform_fees as cogs_total_platform_fees,

        -- shopify order calculated fields
        socf.customer_type,
        socf.is_refunded,
        socf.IS_SUBSCRIPTION_RECURRING_ORDER,
        socf.IS_SUBSCRIPTION_ORDER,
        socf.is_recharge_order,
        socf.IS_RENEWAL_ORDER,
        socf.IS_REACTIVATION_ORDER,
        socf.FIRST_TIME_CUSTOMER_ORDER,
        socf.SUBSCRIPTION_FIRST_ORDER,
        socf.IS_TIKTOK_SHOP,
        socf.IS_KLAVIYO,
        socf.IS_SNAPCHAT,

        -- shopify additional details
        sa.shopify_additional_details_offer,
        sa.shopify_additional_details_offer_name,
        sa.shopify_additional_details_sale_name,

        -- Supporting fields for COGS calculations
        ol.product_weight_pounds,
        ol.packout_units,
        null as IS_SUBSCRIBE_AND_SAVE

    from {{ ref('int_shopify_order_line') }} ol
    left join shopify_order_calculated_fields socf
        on ol.order_id = socf.order_id
    left join shopify_additional_details sa
        on ol.order_id = sa.order_id
)


select * from final
