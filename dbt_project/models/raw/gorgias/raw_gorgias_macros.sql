-- models\raw\gorgias\raw_macros.sql

SELECT  
    ID AS MACRO_ID,  
    NAME AS MACRO_NAME,  
    URI AS MACRO_URI,  
    INTENT AS MACRO_INTENT,  
    LANGUAGE AS MACRO_LANGUAGE,
    USAGE AS USAGE_FROM_TICKETS,
    CREATED_DATETIME,
    UPDATED_DATETIME 
FROM {{ source('portable_gorgias','macros') }}