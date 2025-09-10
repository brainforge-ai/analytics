-- models\marts\customer_service\ticket_field_usage_summary.sql

SELECT 
    FIELD_ID,
    FIELD_LABEL,
    FIELD_DESCRIPTION,
    FIELD_VALUE,
    COUNT(DISTINCT TICKET_ID) AS FIELD_USAGE_COUNT,  -- Count how many unique tickets have used this field
    ARRAY_AGG(DISTINCT TICKET_ID) AS TICKET_IDS      -- List of ticket IDs that have used this field
FROM {{ ref('fact_ticket_fields') }} 
GROUP BY FIELD_ID, FIELD_LABEL, FIELD_DESCRIPTION, FIELD_VALUE            
ORDER BY FIELD_USAGE_COUNT DESC
