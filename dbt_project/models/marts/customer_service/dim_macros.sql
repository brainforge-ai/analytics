-- models\marts\customer_service\dim_macros.sql

SELECT 
    MACRO_ID,  
    MACRO_NAME,  
    MACRO_URI,  
    MACRO_INTENT,  
    MACRO_LANGUAGE,
    USAGE_FROM_TICKETS,
    CREATED_DATETIME,
    UPDATED_DATETIME 
FROM {{ ref('raw_gorgias_macros') }}