-- Potential API endpoint: https://developer-docs.amazon.com/sp-api/docs/listings-items-api-v2021-08-01-model

SELECT 
    li.SKU,   -- Check if we need to bring SKU from the dummyclient's "ETL - Product Cost" source Spreadsheet -- SKUs are seller-defined for inventory management.
    lis.ASIN, -- Amazon Standard Identification Number (ASIN) is defined by Amazon and it is a unique identifier for products on Amazon.
    lis.ITEM_NAME,
    lis.PRODUCT_TYPE,
    lis.HEIGHT,
    lis.WIDTH,
    lis.LINK as PRODUCT_IMAGE_URL,
    lis.CREATED_DATE as CREATED_DATE,
    lis.LAST_UPDATED_DATE as LAST_UPDATED_DATE
FROM {{ source('amazon_raw','LISTED_ITEM') }} AS li
LEFT JOIN {{ source('amazon_raw','LISTED_ITEM_SUMMARY') }} AS lis
    ON li.SKU = lis.SKU