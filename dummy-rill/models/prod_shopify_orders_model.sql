    SELECT *
    FROM prod_fact_orders
    WHERE IS_TIKTOK_SHOP = FALSE AND app_source = 'Shopify'
