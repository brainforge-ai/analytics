-- This model includes both Shopify and Amazon SKUs-level data
-- The model combines product data from Shopify and Amazon into a single table.

with shopify_product as (
    select 
        -- primary keys and identifiers
        sol.product_id as product_id,         -- unique id for the product (all variants share the same product_id)
        sol.order_line_name as product_name,  -- name of the product
        sol.sku,                              -- SKU of the product
        
        -- product attributes
        sol.product_category,  -- product category
        sol.product_flavor,    -- flavor or variant of the product
        sol.product_type,      -- type of the product
        sol.variant_id,        -- Unique identifier for a specific variant of a product in Shopify (e.g., size M, color red).

        -- product metrics
        sol.product_weight_pounds,  -- weight of the product
        -- sol.product_weight_pounds_rounded,
        sol.packout_units,
        
        -- pricing and costs
        -- CHECK IF WE NEED THIS HERE AND HOW THIS SHOULD BE DONE (from fact_orders?)
        sol.price,                   -- CHECK HOW TO BRING LOGIC HERE
        sol.product_cost,                -- cost of the product
        -- sol.unit_platform_fees,       -- platform fees per unit
        -- sol.unit_pick_cost,           -- picking cost per unit
        -- sol.cogs_unit_product_cost,   -- cogs for product
        -- sol.cogs_total_product_cost,  -- total cogs

        -- packaging information
        -- DO WE WANT TO BRING SIZE AND WEIGHT HERE?
        
        -- Platform (specific to shopify)
        sol.app_source,  -- includes both 'TikTok' and 'Shopify' values
        
        -- metadata
        -- current_timestamp as created_at,  -- timestamp when the product or SKU is added ???
        -- current_timestamp as updated_at   -- timestamp of the last product or SKU update ???
    from {{ ref('int_shopify_order_line') }} sol
)
select * from shopify_product


