
with dates as (
    select
        amazon_order_id as id,
        purchase_date as order_created_date
    from {{ source('amazon_raw', 'ORDERS') }}
),
subscribe_and_save as (
    select distinct AMAZON_ORDER_ID, ORDER_ITEM_ID, True as IS_SUBSCRIBE_AND_SAVE
    from {{ source('amazon_raw', 'ORDER_ITEM_PROMOTION_ID') }}
    where
    lower(promotion_id) like '%subscribe & save%' 
    OR lower(promotion_id) like '%subscribe&save%' 
    OR lower(promotion_id) like '%subscribe and save%'
),
default_values as (
    select 
        CAST(REPLACE(product_cost, '$', '') AS DECIMAL(18,4)) as product_cost,
        product_weight_pounds,
        packout_units
    from {{ source('PORTABLE_GOOGLE_SHEETS_ETL_PRODUCT_COST', 'SPREADSHEET_VALUES') }}
    where lower(sku) = 'default'
),

final as (
    select
        dates.order_created_date,
        oi.amazon_order_id,
        oi.order_item_id,
        IFNULL(sns.IS_SUBSCRIBE_AND_SAVE, False) as IS_SUBSCRIBE_AND_SAVE,
        oi.asin as asin_id,
        oi.seller_sku,
        oi.title as product_title,
        oi.title as product_name,
        {{ get_product_category('oi.title', 'oi.title') }} as product_category,
        {{ get_product_flavor('oi.title') }} as product_flavor,
        oi.quantity_ordered,
        oi.quantity_shipped,
        oi.item_price_amount,
        oi.shipping_price_amount,
        oi.shipping_discount_tax_amount,
        oi.item_tax_amount,
        oi.promotion_discount_amount,
        oi.promotion_discount_tax_amount,
        oi.shipping_tax_amount,
        oi.shipping_discount_amount,
        pc.sku_name,
        case 
            when pc.product_cost = '' then dv.product_cost
            else coalesce(CAST(REPLACE(pc.product_cost, '$', '') AS DECIMAL(18,4)), dv.product_cost)
        end as product_cost,
        coalesce(case when pc.product_weight_pounds = '' then null else pc.product_weight_pounds end, dv.product_weight_pounds) as product_weight_pounds,
        coalesce(case when pc.packout_units = '' then null else pc.packout_units end, dv.packout_units) as packout_units,
        
        -- New COGS fields at line item level
        CAST(REPLACE(sa.shipping_cost, '$', '') AS DECIMAL(18,4)) as unit_shipping_cost,
        nvl(CAST(REPLACE(bd.box_cost, '$', '') AS DECIMAL(18,4)), 0) as unit_box_cost,
        nvl(CAST(REPLACE(pf.cost, '$', '') AS DECIMAL(18,4)), 0) as unit_pick_cost,
        nvl(CAST(REPLACE(plf.fee, '$', '') AS DECIMAL(18,4)), 0) / 100 as unit_platform_fees,
        
        -- Total COGS calculations (multiplied by quantity)
        CAST(REPLACE(sa.shipping_cost, '$', '') AS DECIMAL(18,4)) * oi.quantity_ordered as total_shipping_cost,
        nvl(CAST(REPLACE(bd.box_cost, '$', '') AS DECIMAL(18,4)), 0) * oi.quantity_ordered as total_box_cost,
        nvl(CAST(REPLACE(pf.cost, '$', '') AS DECIMAL(18,4)), 0) * oi.quantity_ordered as total_pick_cost,
        nvl(CAST(REPLACE(plf.fee, '$', '') AS DECIMAL(18,4)), 0) / 100 * oi.quantity_ordered as total_platform_fees,

        -- nvl(coalesce(CAST(REPLACE(pc.product_cost, '$', '') AS DECIMAL(18,4)), dv.product_cost), 0) as product_cost,
        -- nvl(coalesce(pc.product_weight_pounds, dv.product_weight_pounds), 0) as product_weight_pounds,
        -- nvl(coalesce(pc.packout_units, dv.packout_units), 0) as packout_units
    from {{ source('amazon_raw', 'ORDER_ITEM') }} oi
    left join dates 
        on oi.amazon_order_id = dates.id
    left join subscribe_and_save sns
        on oi.amazon_order_id = sns.amazon_order_id
        and oi.order_item_id = sns.order_item_id
    left join (
        select * from {{ source('PORTABLE_GOOGLE_SHEETS_ETL_PRODUCT_COST', 'SPREADSHEET_VALUES') }} 
        Qualify row_number() over(partition by lower(app_source), lower(sku) order by _portable_extracted desc) = 1
    )pc
        on lower(pc.sku) = lower(oi.seller_sku)
        and lower(pc.app_source) = 'amazon'
    cross join default_values dv

    -- Add COGS related joins
    left join {{ source('PORTABLE_GOOGLE_SHEETS_SHIPPING_ASSUMPTIONS','SPREADSHEET_VALUES')}} sa
        on round(coalesce(case when pc.product_weight_pounds = '' then null else pc.product_weight_pounds end, dv.product_weight_pounds),0) = sa.weight_pounds
    left join {{ source('PORTABLE_GOOGLE_SHEETS_BOX_COST_DUNNAGE_ASSUMPTIONS','SPREADSHEET_VALUES')}} bd
        on coalesce(case when pc.packout_units = '' then null else pc.packout_units end, dv.packout_units) = bd.units
    left join {{ source('PORTABLE_GOOGLE_SHEETS_PICK_FEES_ASSUMPTIONS','SPREADSHEET_VALUES')}} pf
        on coalesce(case when pc.packout_units = '' then null else pc.packout_units end, dv.packout_units) = pf.units
    left join {{ source('PORTABLE_GOOGLE_SHEETS_PLATFORM_FEES_ASSUMPTIONS','SPREADSHEET_VALUES')}} plf
        on plf.app_source = 'Amazon'
)

select * from final
