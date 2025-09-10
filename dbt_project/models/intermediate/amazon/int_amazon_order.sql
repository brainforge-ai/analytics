WITH metrics AS (

SELECT
    amazon_order_id::string as amazon_order_id,
    ARRAY_AGG(DISTINCT product_title) AS product_names,
    lower(listagg(DISTINCT product_name, ', ')) as product_name_list,
    SUM(IFNULL(quantity_ordered,0)) AS order_item_quantity,
    SUM(IFNULL(item_price_amount,0)) AS total_item_price_amount,
    SUM(IFNULL(shipping_price_amount,0)) AS shipping_price_amount,
    SUM(IFNULL(item_tax_amount,0)) AS item_tax_amount,
    SUM(IFNULL(shipping_tax_amount,0)) AS shipping_tax_amount,
    SUM(IFNULL(shipping_discount_amount,0)) AS shipping_discount_amount,
    SUM(IFNULL(shipping_discount_tax_amount,0)) AS shipping_discount_tax_amount,
    SUM(IFNULL(promotion_discount_amount,0)) AS promotion_discount_amount,
    SUM(IFNULL(promotion_discount_tax_amount,0)) AS promotion_discount_tax_amount
FROM {{ ref('int_amazon_order_line') }}
WHERE amazon_order_id IS NOT NULL
GROUP BY 1

),
subscribe_and_save as (
    select distinct AMAZON_ORDER_ID, True as IS_SUBSCRIBE_AND_SAVE
    from {{ source('amazon_raw', 'ORDER_ITEM_PROMOTION_ID') }}
    where
    lower(promotion_id) like '%subscribe & save%' 
    OR lower(promotion_id) like '%subscribe&save%' 
    OR lower(promotion_id) like '%subscribe and save%'
),
customer_data AS (
SELECT
    'Amazon' AS app_source,
    CASE 
        WHEN buyer_info_buyer_email IS NOT NULL 
            THEN md5(buyer_info_buyer_email)::string
        WHEN shipping_address_state_or_region is null and shipping_address_postal_code is null 
            THEN md5(ao.amazon_order_id)::string
        ELSE md5(ifnull(ao.shipping_address_name, '') || 
                    ifnull(ao.shipping_address_city, '') || 
                    ifnull(ao.shipping_address_postal_code, '') || 
                    ifnull(ao.shipping_address_state_or_region, ''))::string
    END as customer_id,
    ao.AMAZON_ORDER_ID::string as amazon_order_id,
    ao.SELLER_ORDER_ID::string as seller_order_id,
    ao.buyer_info_buyer_email, --for customer first/second order
    row_number() over (partition by ao.buyer_info_buyer_email order by ao.PURCHASE_DATE asc) as customer_order_number,
    ao.PURCHASE_DATE AS CREATED_DATE,
    ao.LAST_UPDATE_DATE AS UPDATED_DATE,
    ao.ORDER_STATUS,
    ao.FULFILLMENT_CHANNEL,
    ao.SALES_CHANNEL,
    ao.SHIP_SERVICE_LEVEL,
    ao.ORDER_TOTAL_CURRENCY_CODE AS CURRENCY_CODE,
    ao.ORDER_TOTAL_AMOUNT,
    ao.NUMBER_OF_ITEMS_SHIPPED AS QUANTITY,
    m.ORDER_ITEM_QUANTITY,
    m.TOTAL_ITEM_PRICE_AMOUNT,
    m.product_names,

    case 
        when m.product_name_list like '%protein%' and m.product_name_list like '%concentrate%' then 'both'
        when m.product_name_list like '%protein%' then 'protein'
        when m.product_name_list like '%concentrate%' then 'concentrate'
    end as funnel_type,
    IFNULL(sns.IS_SUBSCRIBE_AND_SAVE, False) as IS_SUBSCRIBE_AND_SAVE,

    -- item taxes   
    m.ITEM_TAX_AMOUNT,
    m.ITEM_TAX_AMOUNT + m.SHIPPING_TAX_AMOUNT + m.PROMOTION_DISCOUNT_TAX_AMOUNT as total_tax,

    -- shipping fees
    m.SHIPPING_PRICE_AMOUNT,
    m.SHIPPING_PRICE_AMOUNT - m.SHIPPING_DISCOUNT_AMOUNT as shipping_discounted_price,
    m.SHIPPING_TAX_AMOUNT,
    m.SHIPPING_DISCOUNT_AMOUNT,
    m.SHIPPING_DISCOUNT_TAX_AMOUNT,

    -- promotion discounts
    m.PROMOTION_DISCOUNT_AMOUNT,
    m.PROMOTION_DISCOUNT_AMOUNT + m.SHIPPING_DISCOUNT_AMOUNT as total_discounts,
    m.PROMOTION_DISCOUNT_TAX_AMOUNT,
    ao.IS_PRIME,

    -- shipping address
    ao.shipping_address_phone,
    ao.shipping_address_address_line_1,
    ao.shipping_address_address_line_2,
    ao.shipping_address_name,
    ao.SHIPPING_ADDRESS_CITY,
    ao.SHIPPING_ADDRESS_STATE_OR_REGION,
    ao.SHIPPING_ADDRESS_POSTAL_CODE,
    ao.SHIPPING_ADDRESS_COUNTRY_CODE

FROM {{ source('amazon_raw','ORDERS')}} ao
LEFT JOIN metrics m
    ON ao.amazon_order_id = m.amazon_order_id
LEFT JOIN subscribe_and_save sns
    ON ao.amazon_order_id = sns.amazon_order_id
)

SELECT
    *,
    CASE 
        WHEN row_number() over (partition by customer_id order by CREATED_DATE asc) > 1 
        THEN TRUE 
        ELSE FALSE 
    END as is_returning_customer
FROM customer_data
