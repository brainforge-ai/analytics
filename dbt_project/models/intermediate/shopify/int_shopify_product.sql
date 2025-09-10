
SELECT
    distinct
    p.ID AS PRODUCT_ID,
    'SHOPIFY' AS SOURCE_SYSTEM,
    p.TITLE AS PRODUCT_TITLE,
    p.HANDLE,
    CASE WHEN p.PRODUCT_TYPE = '' THEN pc.product_type ELSE p.PRODUCT_TYPE END AS PRODUCT_TYPE,
    p.VENDOR,
    p.CREATED_AT,
    p.UPDATED_AT,
    p.PUBLISHED_AT,
    p.PUBLISHED_SCOPE,
    p.STATUS,
    p.tags as PRODUCT_TAGS,
    p.TEMPLATE_SUFFIX AS SUFFIX
FROM  {{ source('portable_shopify','products')}} p
left join {{ ref('product_category_mapping')}} pc
    on pc.title = p.title
    