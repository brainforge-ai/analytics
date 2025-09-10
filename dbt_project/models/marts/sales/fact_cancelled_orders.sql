WITH 
shopify_orders AS (

    SELECT
        o.app_source,
        o.order_id::string as order_id, 
        o.CUSTOMER_TYPE,
        o.TIKTOK_ORDER_ID, 
        o.customer_id, 
        o.CREATED_AT, 
        o.UPDATED_AT, 
        o.PROCESSED_AT, 
        o.CLOSED_AT, 
        o.CANCELLED_AT, 
        o.CANCEL_REASON, 
        o.ORDER_NAME, 
        o.CURRENCY, 
        o.FINANCIAL_STATUS, 
        o.FULFILLMENT_STATUS, 
        o.SUBTOTAL_PRICE, 
        o.TOTAL_TAX, 
        o.TOTAL_PRICE, 
        o.TOTAL_LINE_ITEMS_PRICE,
        o.TOTAL_DISCOUNTS, 
        o.DISCOUNT_CODE, 
        o.CURRENT_TOTAL_PRICE, 
        o.CURRENT_TOTAL_DISCOUNTS, 
        o.CURRENT_SUBTOTAL_PRICE, 
        o.CURRENT_TOTAL_TAX, 
        o.FEE_AMOUNT,
        o.refund_created_at,
        o.refund_processed_at,
        o.REFUND_AMOUNT, 
        o.REFUND_CODE, 
        o.REFUND_REASON, 
        o.SHIPPING_PRICE as shipping_price_base, 
        o.SHIPPING_DISCOUNTED_PRICE as shipping_price_final, 
        o.shipping_discount_amount,
        o.SHIPPING_CODE, 
        o.SHIPPING_ADDRESS1 as shipping_address_address_line_1,
        o.SHIPPING_ADDRESS2 as shipping_address_address_line_2,
        o.SHIPPING_ADDRESS_CITY, 
        o.SHIPPING_ADDRESS_COUNTRY, 
        o.SHIPPING_ADDRESS_COUNTRY_CODE, 
        o.SHIPPING_ADDRESS_PROVINCE, 
        o.SHIPPING_ADDRESS_PROVINCE_CODE, 
        o.SHIPPING_ADDRESS_LATITUDE, 
        o.SHIPPING_ADDRESS_LONGITUDE, 
        o.SHIPPING_ADDRESS_ZIP as shipping_address_postal_code,
        o.CUSTOMER_ORDER_NUMBER,

        -- shopify order calculated fields
        o.is_tiktok_shop,
        o.is_klaviyo,
        o.is_snapchat,
        o.IS_SUBSCRIPTION_ORDER,
        o.is_recharge_order,
        null as IS_SUBSCRIBE_AND_SAVE,

        -- shopify additional details
        o.offer,
        o.offer_name,
        o.sale_name,

        -- cogs
        soc.cogs_product_cost,
        soc.cogs_product_weight_pounds,
        soc.cogs_product_weight_pounds_rounded,
        soc.cogs_packout_units,
        soc.order_shipping_cost,
        soc.order_box_cost,
        soc.order_pick_cost,
        o.processing_fee as processing_fee,
        (o.TOTAL_LINE_ITEMS_PRICE::float - o.TOTAL_DISCOUNTS::float + o.shipping_discounted_price) * (soc.plf_fee / 100) as platform_fee,
        CASE 
            WHEN o.IS_SUBSCRIPTION_ORDER and o.customer_type = 'New' THEN 'New Subscriptions'
            WHEN o.IS_SUBSCRIPTION_ORDER and o.customer_type = 'Returning' THEN 'Returning Subscriptions'
            WHEN o.IS_SUBSCRIPTION_ORDER = FALSE and o.customer_type = 'New' THEN 'New Non-Subscriptions'
            WHEN o.IS_SUBSCRIPTION_ORDER = FALSE and o.customer_type = 'Returning' THEN 'Returning Non-Subscriptions'
            ELSE 'Uncategorized'
        END as subscription_customer_category,

        -- Add product names from int_shopify_order
        o.product_names,
        o.funnel_type,

    FROM {{ ref('int_shopify_order') }} o 
    left join {{ref('int_shopify_order_cogs')}} soc
        on o.order_id = soc.order_id
    WHERE o.cancelled_at is not null

),

final as (
     
    select
        distinct
        order_id,
        customer_id,
        customer_type,
        created_at,
        app_source,
        ifnull(total_price, 0) as total_price,
        ifnull(total_line_items_price, 0) as total_line_items_price,
        ifnull(total_discounts, 0) as total_discounts,
        ifnull(shipping_price_base, 0) as shipping_price_base,
        ifnull(shipping_discount_amount, 0) as shipping_discount_amount,
        ifnull(shipping_price_final, 0) as shipping_price_final,
        refund_amount,
        is_tiktok_shop,
        is_klaviyo,
        is_snapchat,
        is_subscription_order,
        is_recharge_order,
        offer,
        offer_name,
        sale_name,
        ifnull(cogs_product_cost, 0) as cogs_product_cost,
        cogs_product_weight_pounds,
        cogs_product_weight_pounds_rounded,
        cogs_packout_units,
        ifnull(order_shipping_cost, 0) as order_shipping_cost,
        ifnull(order_box_cost, 0) as order_box_cost,
        ifnull(order_pick_cost, 0) as order_pick_cost,
        subscription_customer_category,
        financial_status,
        fulfillment_status,
        shipping_address_address_line_1,
        shipping_address_address_line_2,
        shipping_address_city,
        shipping_address_country,
        shipping_ADDRESS_country_code,
        shipping_address_province,
        shipping_address_province_code,
        shipping_address_latitude,
        shipping_address_longitude,
        shipping_address_postal_code,
        product_names, -- Include product names in the final output
        funnel_type,
        ifnull(processing_fee, 0) as processing_fee,
        ifnull(platform_fee, 0) as platform_fee,
        IS_SUBSCRIBE_AND_SAVE,
        total_tax,
        CANCELLED_AT, 
        CANCEL_REASON,
    from shopify_orders
)

select
    *,
    ROW_NUMBER() OVER (
        PARTITION BY customer_id
        ORDER BY CASE WHEN is_subscription_order THEN created_at ELSE NULL END
    ) = 1 as is_first_subscription_order
from final
