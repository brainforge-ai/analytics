-- models\marts\customer_service\dim_ticket_fields.sql

SELECT
    TICKET_ID,
    CUSTOM_FIELD_ID,
    FIELD_ID,
    FIELD_LABEL,
    FIELD_DESCRIPTION,
    FIELD_VALUE,
    UPDATED_DATETIME
FROM {{ ref('raw_gorgias_ticket_fields') }}
WHERE CUSTOM_FIELD_ID IS NOT NULL    -- filter out null values from CUSTOM_FIELD_ID if not needed
    AND FIELD_ID IS NOT NULL         -- filter out null values from FIELD_ID within CUSTOM_FIELD_ID if not needed 