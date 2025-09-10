
with order_kpis as (
    select
        app_source,

        CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', CAST(CREATED_AT AS TIMESTAMP_NTZ)) as date_day,
        DAYOFWEEK(CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', CAST(CREATED_AT AS TIMESTAMP_NTZ))) as day_of_week,
        DAYNAME(CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', CAST(CREATED_AT AS TIMESTAMP_NTZ))) as day_name,
        month( CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', CAST(CREATED_AT AS TIMESTAMP_NTZ))) as date_month,
        year(CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', CAST(CREATED_AT AS TIMESTAMP_NTZ))) as date_year,
        DAYOFYEAR(CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', CAST(CREATED_AT AS TIMESTAMP_NTZ))) as day_of_year,
        
        -- Order Counts
        count(order_id) as total_orders,
        sum(case when customer_type = 'New' AND IS_SUBSCRIPTION_ORDER = TRUE then 1 else 0 end) as new_subs_orders,
        sum(case when customer_type = 'New' AND IS_SUBSCRIPTION_ORDER = FALSE then 1 else 0 end) as new_non_subs_orders,
        sum(case when IS_SUBSCRIPTION_ORDER = TRUE then 1 else 0 end) as total_subs_orders,
        sum(case when customer_type = 'Returning' AND IS_SUBSCRIPTION_ORDER = TRUE then 1 else 0 end) as return_subs_orders,
        sum(case when customer_type = 'Returning' AND IS_SUBSCRIPTION_ORDER = FALSE then 1 else 0 end) as return_non_subs_orders,
        sum(case when customer_type = 'Returning' then 1 else 0 end) as total_return_orders,

        -- Gross Sales
        NVL(sum(total_line_items_price), 0) as total_gross_sales,
        NVL(sum(case when customer_type = 'New' AND IS_SUBSCRIPTION_ORDER = TRUE then total_line_items_price else 0 end), 0) as new_subs_gross_sales,
        NVL(sum(case when customer_type = 'New' AND IS_SUBSCRIPTION_ORDER = FALSE then total_line_items_price else 0 end), 0) as new_non_subs_gross_sales,
        NVL(sum(case when IS_SUBSCRIPTION_ORDER = TRUE then total_line_items_price else 0 end), 0) as total_subs_gross_sales,
        NVL(sum(case when customer_type = 'Returning' AND IS_SUBSCRIPTION_ORDER = TRUE then total_line_items_price else 0 end), 0) as return_subs_gross_sales,
        NVL(sum(case when customer_type = 'Returning' AND IS_SUBSCRIPTION_ORDER = FALSE then total_line_items_price else 0 end), 0) as return_non_subs_gross_sales,
        NVL(sum(case when customer_type = 'Returning' then total_line_items_price else 0 end), 0) as total_return_gross_sales,

        -- Shipping
        NVL(sum(shipping_price_final), 0) as total_shipping,
        NVL(sum(case when customer_type = 'New' AND IS_SUBSCRIPTION_ORDER = TRUE then shipping_price_final else 0 end), 0) as new_subs_shipping,
        NVL(sum(case when customer_type = 'New' AND IS_SUBSCRIPTION_ORDER = FALSE then shipping_price_final else 0 end), 0) as new_non_subs_shipping,
        NVL(sum(case when IS_SUBSCRIPTION_ORDER = TRUE then shipping_price_final else 0 end), 0) as total_subs_shipping,
        NVL(sum(case when customer_type = 'Returning' AND IS_SUBSCRIPTION_ORDER = TRUE then shipping_price_final else 0 end), 0) as return_subs_shipping,
        NVL(sum(case when customer_type = 'Returning' AND IS_SUBSCRIPTION_ORDER = FALSE then shipping_price_final else 0 end), 0) as return_non_subs_shipping,
        NVL(sum(case when customer_type = 'Returning' then shipping_price_final else 0 end), 0) as total_return_shipping,

        -- Discounts
        NVL(sum(TOTAL_DISCOUNTS), 0) as total_discounts,
        NVL(sum(case when customer_type = 'New' AND IS_SUBSCRIPTION_ORDER = TRUE then TOTAL_DISCOUNTS else 0 end), 0) as new_subs_discounts,
        NVL(sum(case when customer_type = 'New' AND IS_SUBSCRIPTION_ORDER = FALSE then TOTAL_DISCOUNTS else 0 end), 0) as new_non_subs_discounts,
        NVL(sum(case when IS_SUBSCRIPTION_ORDER = TRUE then TOTAL_DISCOUNTS else 0 end), 0) as total_subs_discounts,
        NVL(sum(case when customer_type = 'Returning' AND IS_SUBSCRIPTION_ORDER = TRUE then TOTAL_DISCOUNTS else 0 end), 0) as return_subs_discounts,
        NVL(sum(case when customer_type = 'Returning' AND IS_SUBSCRIPTION_ORDER = FALSE then TOTAL_DISCOUNTS else 0 end), 0) as return_non_subs_discounts,
        NVL(sum(case when customer_type = 'Returning' then TOTAL_DISCOUNTS else 0 end), 0) as total_return_discounts,

        -- Net Sales (excluding shipping)
        NVL(sum(TOTAL_LINE_ITEMS_PRICE - TOTAL_DISCOUNTS + REFUND_AMOUNT), 0) as total_net_sales,
        NVL(sum(case when customer_type = 'New' AND IS_SUBSCRIPTION_ORDER = TRUE then (TOTAL_LINE_ITEMS_PRICE - TOTAL_DISCOUNTS + REFUND_AMOUNT) else 0 end), 0) as new_subs_net_sales,
        NVL(sum(case when customer_type = 'New' AND IS_SUBSCRIPTION_ORDER = FALSE then (TOTAL_LINE_ITEMS_PRICE - TOTAL_DISCOUNTS + REFUND_AMOUNT) else 0 end), 0) as new_non_subs_net_sales,
        NVL(sum(case when IS_SUBSCRIPTION_ORDER = TRUE then (TOTAL_LINE_ITEMS_PRICE - TOTAL_DISCOUNTS + REFUND_AMOUNT) else 0 end), 0) as total_subs_net_sales,
        NVL(sum(case when customer_type = 'Returning' AND IS_SUBSCRIPTION_ORDER = TRUE then (TOTAL_LINE_ITEMS_PRICE - TOTAL_DISCOUNTS + REFUND_AMOUNT) else 0 end), 0) as return_subs_net_sales,
        NVL(sum(case when customer_type = 'Returning' AND IS_SUBSCRIPTION_ORDER = FALSE then (TOTAL_LINE_ITEMS_PRICE - TOTAL_DISCOUNTS + REFUND_AMOUNT) else 0 end), 0) as return_non_subs_net_sales,
        NVL(sum(case when customer_type = 'Returning' then (TOTAL_LINE_ITEMS_PRICE - TOTAL_DISCOUNTS + REFUND_AMOUNT) else 0 end), 0) as total_return_net_sales,

        -- Net Sales (including shipping)
        NVL(sum(TOTAL_LINE_ITEMS_PRICE - TOTAL_DISCOUNTS + REFUND_AMOUNT + shipping_price_final), 0) as total_net_sales_with_shipping,
        NVL(sum(case when customer_type = 'New' AND IS_SUBSCRIPTION_ORDER = TRUE then (TOTAL_LINE_ITEMS_PRICE - TOTAL_DISCOUNTS + REFUND_AMOUNT + shipping_price_final) else 0 end), 0) as new_subs_net_sales_with_shipping,
        NVL(sum(case when customer_type = 'New' AND IS_SUBSCRIPTION_ORDER = FALSE then (TOTAL_LINE_ITEMS_PRICE - TOTAL_DISCOUNTS + REFUND_AMOUNT + shipping_price_final) else 0 end), 0) as new_non_subs_net_sales_with_shipping,
        NVL(sum(case when IS_SUBSCRIPTION_ORDER = TRUE then (TOTAL_LINE_ITEMS_PRICE - TOTAL_DISCOUNTS + REFUND_AMOUNT + shipping_price_final) else 0 end), 0) as total_subs_net_sales_with_shipping,
        NVL(sum(case when customer_type = 'Returning' AND IS_SUBSCRIPTION_ORDER = TRUE then (TOTAL_LINE_ITEMS_PRICE - TOTAL_DISCOUNTS + REFUND_AMOUNT + shipping_price_final) else 0 end), 0) as return_subs_net_sales_with_shipping,
        NVL(sum(case when customer_type = 'Returning' AND IS_SUBSCRIPTION_ORDER = FALSE then (TOTAL_LINE_ITEMS_PRICE - TOTAL_DISCOUNTS + REFUND_AMOUNT + shipping_price_final) else 0 end), 0) as return_non_subs_net_sales_with_shipping,
        NVL(sum(case when customer_type = 'Returning' then (TOTAL_LINE_ITEMS_PRICE - TOTAL_DISCOUNTS + REFUND_AMOUNT + shipping_price_final) else 0 end), 0) as total_return_net_sales_with_shipping,

        -- COGS
        -- We commented out the total_product_cost calculations because we are not using them in fact_orders
        -- NVL(sum(total_product_cost), 0) as total_cogs,
        -- NVL(sum(case when customer_type = 'New' AND IS_SUBSCRIPTION_ORDER = TRUE then total_product_cost else 0 end), 0) as new_subs_cogs,
        -- NVL(sum(case when customer_type = 'New' AND IS_SUBSCRIPTION_ORDER = FALSE then total_product_cost else 0 end), 0) as new_non_subs_cogs,
        -- NVL(sum(case when IS_SUBSCRIPTION_ORDER = TRUE then total_product_cost else 0 end), 0) as total_subs_cogs,
        -- NVL(sum(case when customer_type = 'Returning' AND IS_SUBSCRIPTION_ORDER = TRUE then total_product_cost else 0 end), 0) as return_subs_cogs,
        -- NVL(sum(case when customer_type = 'Returning' AND IS_SUBSCRIPTION_ORDER = FALSE then total_product_cost else 0 end), 0) as return_non_subs_cogs,
        -- NVL(sum(case when customer_type = 'Returning' then total_product_cost else 0 end), 0) as total_return_cogs

        -- COGS
        -- These are the same as above, but with cogs_product_cost instead of total_product_cost (because we are not using total_product_cost in fact_orders anymore)
        NVL(sum(cogs_product_cost), 0) as total_cogs,
        NVL(sum(case when customer_type = 'New' AND IS_SUBSCRIPTION_ORDER = TRUE then cogs_product_cost else 0 end), 0) as new_subs_cogs,
        NVL(sum(case when customer_type = 'New' AND IS_SUBSCRIPTION_ORDER = FALSE then cogs_product_cost else 0 end), 0) as new_non_subs_cogs,
        NVL(sum(case when IS_SUBSCRIPTION_ORDER = TRUE then cogs_product_cost else 0 end), 0) as total_subs_cogs,
        NVL(sum(case when customer_type = 'Returning' AND IS_SUBSCRIPTION_ORDER = TRUE then cogs_product_cost else 0 end), 0) as return_subs_cogs,
        NVL(sum(case when customer_type = 'Returning' AND IS_SUBSCRIPTION_ORDER = FALSE then cogs_product_cost else 0 end), 0) as return_non_subs_cogs,
        NVL(sum(case when customer_type = 'Returning' then cogs_product_cost else 0 end), 0) as total_return_cogs
    
    from {{ref('fact_orders')}}
    WHERE app_source = 'TikTok'
    group by all

),

final as (
    select
        app_source,

        ok.date_day,
        ok.day_of_week,
        ok.day_name,
        ok.day_of_year,
        ok.date_month,
        ok.date_year,

        -- Order Counts
        ok.total_orders,
        ok.new_subs_orders,
        ok.new_non_subs_orders,
        ok.total_subs_orders,
        ok.return_subs_orders,
        ok.return_non_subs_orders,
        ok.total_return_orders,

        -- Gross Sales
        ok.total_gross_sales,
        ok.new_subs_gross_sales,
        ok.new_non_subs_gross_sales,
        ok.total_subs_gross_sales,
        ok.return_subs_gross_sales,
        ok.return_non_subs_gross_sales,
        ok.total_return_gross_sales,

        -- Shipping
        ok.total_shipping,
        ok.new_subs_shipping,
        ok.new_non_subs_shipping,
        ok.total_subs_shipping,
        ok.return_subs_shipping,
        ok.return_non_subs_shipping,
        ok.total_return_shipping,

        -- Discounts and Discount %
        ok.total_discounts,
        ok.new_subs_discounts,
        ok.new_non_subs_discounts,
        ok.total_subs_discounts,
        ok.return_subs_discounts,
        ok.return_non_subs_discounts,
        ok.total_return_discounts,
        
        DIV0NULL(ok.total_discounts, ok.total_gross_sales) as total_discount_pct,
        DIV0NULL(ok.new_subs_discounts, ok.new_subs_gross_sales) as new_subs_discount_pct,
        DIV0NULL(ok.new_non_subs_discounts, ok.new_non_subs_gross_sales) as new_non_subs_discount_pct,
        DIV0NULL(ok.total_subs_discounts, ok.total_subs_gross_sales) as total_subs_discount_pct,
        DIV0NULL(ok.return_subs_discounts, ok.return_subs_gross_sales) as return_subs_discount_pct,
        DIV0NULL(ok.return_non_subs_discounts, ok.return_non_subs_gross_sales) as return_non_subs_discount_pct,
        DIV0NULL(ok.total_return_discounts, ok.total_return_gross_sales) as total_return_discount_pct,

        -- Net Sales (excluding shipping)
        ok.total_net_sales,
        ok.new_subs_net_sales,
        ok.new_non_subs_net_sales,
        ok.total_subs_net_sales,
        ok.return_subs_net_sales,
        ok.return_non_subs_net_sales,
        ok.total_return_net_sales,

        -- Net Sales (including shipping)
        ok.total_net_sales_with_shipping,
        ok.new_subs_net_sales_with_shipping,
        ok.new_non_subs_net_sales_with_shipping,
        ok.total_subs_net_sales_with_shipping,
        ok.return_subs_net_sales_with_shipping,
        ok.return_non_subs_net_sales_with_shipping,
        ok.total_return_net_sales_with_shipping,

        -- Gross AOV
        DIV0NULL(ok.total_gross_sales, ok.total_orders) as total_gross_aov,
        DIV0NULL(ok.new_subs_gross_sales, ok.new_subs_orders) as new_subs_gross_aov,
        DIV0NULL(ok.new_non_subs_gross_sales, ok.new_non_subs_orders) as new_non_subs_gross_aov,
        DIV0NULL(ok.total_subs_gross_sales, ok.total_subs_orders) as total_subs_gross_aov,
        DIV0NULL(ok.return_subs_gross_sales, ok.return_subs_orders) as return_subs_gross_aov,
        DIV0NULL(ok.return_non_subs_gross_sales, ok.return_non_subs_orders) as return_non_subs_gross_aov,
        DIV0NULL(ok.total_return_gross_sales, ok.total_return_orders) as total_return_gross_aov,

        -- Net AOV (excluding shipping)
        DIV0NULL(ok.total_net_sales, ok.total_orders) as total_net_aov,
        DIV0NULL(ok.new_subs_net_sales, ok.new_subs_orders) as new_subs_net_aov,
        DIV0NULL(ok.new_non_subs_net_sales, ok.new_non_subs_orders) as new_non_subs_net_aov,
        DIV0NULL(ok.total_subs_net_sales, ok.total_subs_orders) as total_subs_net_aov,
        DIV0NULL(ok.return_subs_net_sales, ok.return_subs_orders) as return_subs_net_aov,
        DIV0NULL(ok.return_non_subs_net_sales, ok.return_non_subs_orders) as return_non_subs_net_aov,
        DIV0NULL(ok.total_return_net_sales, ok.total_return_orders) as total_return_net_aov,

        -- Net AOV (including shipping)
        DIV0NULL(ok.total_net_sales_with_shipping, ok.total_orders) as total_net_aov_with_shipping,
        DIV0NULL(ok.new_subs_net_sales_with_shipping, ok.new_subs_orders) as new_subs_net_aov_with_shipping,
        DIV0NULL(ok.new_non_subs_net_sales_with_shipping, ok.new_non_subs_orders) as new_non_subs_net_aov_with_shipping,
        DIV0NULL(ok.total_subs_net_sales_with_shipping, ok.total_subs_orders) as total_subs_net_aov_with_shipping,
        DIV0NULL(ok.return_subs_net_sales_with_shipping, ok.return_subs_orders) as return_subs_net_aov_with_shipping,
        DIV0NULL(ok.return_non_subs_net_sales_with_shipping, ok.return_non_subs_orders) as return_non_subs_net_aov_with_shipping,
        DIV0NULL(ok.total_return_net_sales_with_shipping, ok.total_return_orders) as total_return_net_aov_with_shipping,

        -- COGS
        ok.total_cogs,
        ok.new_subs_cogs,
        ok.new_non_subs_cogs,
        ok.total_subs_cogs,
        ok.return_subs_cogs,
        ok.return_non_subs_cogs,
        ok.total_return_cogs

    from order_kpis ok
)

select * from final